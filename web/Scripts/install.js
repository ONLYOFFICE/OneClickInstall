/*
 *
 * (c) Copyright Ascensio System Limited 2010-2015
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and limitations under the License.
 *
 * You can contact Ascensio System SIA by email at sales@onlyoffice.com
 *
*/

var InstallationProgressStep = {
    Start: 0,
    UploadFiles: 1,
    GetOsInfo: 2,
    CheckPorts: 3,
    InstallDocker: 4,
    RebootServer: 5,
    InstallDocumentServer: 6,
    InstallMailServer: 7,
    InstallCommunityServer: 8,
    WarmUp: 9,
    End: 10
};

var SetupInfo = {
    connectionSettings: null,
    installedComponents: null,
    selectedComponents: null,
    installationProgress: null
};

var InstallManager = (function () {

    var uploadFileUrl;
    var connectUrl;
    var startInstallUrl;
    var installProgressUrl;
    var sendEmailUrl;

    var installForms = {
        connectionForm: {
            switcher: $(".switcher-container .switcher-btn.connection"),
            form: $("#connectionForm"),
            formDesc: $("#connectionFormDesc")
        },
        setupForm: {
            switcher: $(".switcher-container .switcher-btn.setup"),
            form: $("#setupForm"),
            formDesc: $("#setupFormDesc")
        },
        settingsForm: {
            switcher: $(".switcher-container .switcher-btn.settings"),
            form: $("#settingsForm"),
            formDesc: $("#settingsFormDesc")
        }          
    };

    var init = function (uploadFileActionUrl, connectActionUrl, startInstallActionUrl, installProgressActionUrl, sendEmailActionUrl) {

        uploadFileUrl = uploadFileActionUrl;
        connectUrl = connectActionUrl;
        startInstallUrl = startInstallActionUrl;
        installProgressUrl = installProgressActionUrl;
        sendEmailUrl = sendEmailActionUrl;

        var targetForm = getTargetForm();

        displayForm(targetForm);
        
        if (installationIsPerformed()) {
            lockForm(true);
            checkInstallProgress();
        }
        
        $("#sshFile").on("change", function () {
            fileChange(this, $("#sshKey"));
        });

        $(".switcher-container .switcher-btn").on("click", function () {
            if ($(this).hasClass("disabled")) return;

            var target = null;

            if ($(this).hasClass("connection"))
                target = installForms.connectionForm;

            if($(this).hasClass("setup"))
                target = installForms.setupForm;
            
            if ($(this).hasClass("settings"))
                target = installForms.settingsForm;

            if (target == null) return;

            displayForm(target);
        });

        $(".custom-radio[data-name=authType]").on("click", function () {
            if ($(this).hasClass("disabled")) return;

            authTypeChange($(this));
        });

        $(".custom-checkbox").on("click", function () {
            if ($(this).hasClass("disabled")) return;

            if ($(this).is("#installMailServerCbx"))
                mailServerChange($(this));

            checkInstallBtnEnabled();
        });

        $("#connectBtn").on("click", function () {
            if ($(this).hasClass("disabled")) return;

            var settings = getConnectionSettings();

            if (settings == null) return;

            connectServer(settings);
        });

        $("#disconnectBtn, #disconnectBtn1").on("click", function () {
            if ($(this).hasClass("disabled")) return;

            connectServer(null);
        });

        $("#installbtn").on("click", function () {
            if ($(this).hasClass("disabled")) return;

            if (SetupInfo.installedComponents && !SetupInfo.installedComponents.isEmpty) {
                Common.blockUI.show("existVersionErrorPop");
                return;
            }

            var settings = SetupInfo.connectionSettings;
            var components = getSelectedComponents();

            if (settings == null || components == null) return;

            startInstall(settings, components);
        });

        $("#notifybtn").on("click", function () {
            if ($(this).hasClass("disabled")) return;

            var email = getNotifyEmail();

            if (email == null) return;

            sendEmail(email);
        });

        $("#connectionForm input")
            .on("keyup", function(event) {
                checkConnectBtnEnabled();

                var code = Common.getKeyCode(event);

                if (code == 13) {
                    if ($(this).is("#host")) {
                        $("#userName").focus();
                    } else if ($(this).is("#userName")) {
                        if ($("#keyType").hasClass("checked"))
                            $("#sshKey").focus();
                        else
                            $("#password").focus();
                    } else if ($(this).is("#sshKey") || $(this).is("#password"))
                        $("#connectBtn").click();
                }
            })
            .on("change", function () {
                checkConnectBtnEnabled();
            });

        $("#mailDomain")
            .on("keyup", function(event) {
                checkInstallBtnEnabled();

                var code = Common.getKeyCode(event);

                if (code == 13) $("#installbtn").click();
            })
            .on("change", function () {
                checkInstallBtnEnabled();
            });

        $("#email")
            .on("keyup", function(event) {
                checkNotifyBtnEnabled();

                var code = Common.getKeyCode(event);

                if (code == 13) $("#notifybtn").click();

            })
            .on("change", function () {
                checkNotifyBtnEnabled();
            });

    };

    function getTargetForm() {

        if (!SetupInfo.connectionSettings)
            return installForms.connectionForm;

        if (SetupInfo.installedComponents)
            return installForms.settingsForm;

        return installForms.setupForm;
    }

    function installationIsPerformed() {
        return SetupInfo.selectedComponents && SetupInfo.installationProgress && !SetupInfo.installationProgress.isCompleted;
    }

    function checkConnectBtnEnabled() {
        var settings = getConnectionSettings();

        if (settings && !installationIsPerformed()) {
            $("#connectBtn").removeClass("disabled");
        } else {
            $("#connectBtn").addClass("disabled");
        }
    }
    
    function checkInstallBtnEnabled() {
        var components = getSelectedComponents();

        if (components && !installationIsPerformed()) {
            $("#installbtn").removeClass("disabled");
        } else {
            $("#installbtn").addClass("disabled");
        }
    }
    
    function checkNotifyBtnEnabled() {
        var email = getNotifyEmail();

        if (email && !installationIsPerformed()) {
            $("#notifybtn").removeClass("disabled");
        } else {
            $("#notifybtn").addClass("disabled");
        }
    }

    function fileChange(inputFile, inputText) {
        var formdata = new window.FormData();

        $.each(inputFile.files, function () {
            formdata.append(inputFile.name, this);
        });

        $.ajax({
            url: uploadFileUrl,
            type: "POST",
            data: formdata,
            dataType: 'json',
            contentType: false,
            processData: false,
            beforeSend: function () {
                Common.loader.show($("#connectionFieldsForm"));
            },
            error: function (error) {
                inputText.val("");
                toastr.error(error.message);
            },
            success: function (data) {
                if (data.success) {
                    inputText.val(data.fileName);
                    toastr.success(data.message);
                } else {
                    inputText.val("");
                    toastr.error(data.message);
                }
            },
            complete: function () {
                Common.loader.hide($("#connectionFieldsForm"));
                checkConnectBtnEnabled();
            }
        });

        return false;
    }

    function displayForm(installForm) {

        if (!installationIsPerformed()) {
            lockForm(false);
        }
        
        refreshSwithcher();
        refreshForm();

        checkConnectBtnEnabled();
        checkInstallBtnEnabled();
        checkNotifyBtnEnabled();

        $(".switcher-container .switcher-btn").removeClass("selected");
        installForm.switcher.addClass("selected").removeClass("disabled");

        $(".form").addClass("display-none");
        installForm.form.removeClass("display-none");

        $(".form-desc").addClass("display-none");
        installForm.formDesc.removeClass("display-none");

    }

    function lockForm(disable) {
        if (disable) {
            $("input").attr("disabled", true);
            $(".button, .custom-radio").addClass("disabled");
            $(".custom-checkbox").not(".installed").addClass("disabled");
        } else {
            $("input").attr("disabled", false);
            $(".button, .custom-radio").removeClass("disabled");
            $(".custom-checkbox").not(".installed").removeClass("disabled");
        }
    }

    function refreshSwithcher() {
        if (SetupInfo.connectionSettings)
            installForms.setupForm.switcher.removeClass("disabled");
        else
            installForms.setupForm.switcher.addClass("disabled");

        if (SetupInfo.installedComponents)
            installForms.settingsForm.switcher.removeClass("disabled");
        else
            installForms.settingsForm.switcher.addClass("disabled");
    }

    function refreshForm() {
        
        if (SetupInfo.connectionSettings) {
            $("#connectionForm .connected, #connectionFormDesc .connected").removeClass("display-none");
            $("#connectionForm .disconnected, #connectionFormDesc .disconnected").addClass("display-none");

            $("#host").val(SetupInfo.connectionSettings.host || "");
            $("#userName").val(SetupInfo.connectionSettings.userName || "");
            $("#password").val(SetupInfo.connectionSettings.password || "");
            $("#sshKey").val(SetupInfo.connectionSettings.sshKey || "");

            if (SetupInfo.connectionSettings.password) {
                $("#keyType").removeClass("checked");
                authTypeChange($("#passwordType").addClass("checked"));
            }
            else if (SetupInfo.connectionSettings.sshKey) {
                $("#passwordType").removeClass("checked");
                authTypeChange($("#keyType").addClass("checked"));
            }

            var url = SetupInfo.connectionSettings.host.indexOf("http") == 0 ?
                SetupInfo.connectionSettings.host :
                "http://" + SetupInfo.connectionSettings.host;
            
            $("#enterBtn").attr("href", url);

        } else {
            $("#connectionForm .connected, #connectionFormDesc .connected").addClass("display-none");
            $("#connectionForm .disconnected, #connectionFormDesc .disconnected").removeClass("display-none");
            $("#connectionForm input").val("");
        }

        if (SetupInfo.installedComponents) {
            $("#setupInfoText, #installbtn, #mailServerSetupDesc").addClass("display-none");
            $("#setupForm .custom-checkbox").removeClass("checked installed").addClass("disabled");
            
            if (SetupInfo.installedComponents.communityServer)
                $("#installCommunityServerCbx").addClass("checked installed");

            if (SetupInfo.installedComponents.documentServer)
                $("#installDocumentServerCbx").addClass("checked installed");

            if (SetupInfo.installedComponents.mailServer)
                $("#installMailServerCbx").addClass("checked installed");

            $("#mailDomain").val(SetupInfo.installedComponents.mailDomain || "").attr("disabled", true).parent().addClass("display-none");

            if (SetupInfo.installedComponents.communityServer && SetupInfo.installedComponents.documentServer && SetupInfo.installedComponents.mailServer)
                $("#updadeSetupOptionsDesc, #disconnectBtn1").addClass("display-none");
            else
                $("#updadeSetupOptionsDesc, #disconnectBtn1").removeClass("display-none");

        } else {
            if (!installationIsPerformed()) {
                $("#setupInfoText").removeClass("display-none");
                $("#setupForm .custom-checkbox").removeClass("checked installed disabled");
                $("#installCommunityServerCbx").addClass("checked disabled");
                $("#installDocumentServerCbx").addClass("checked disabled");
                $("#installMailServerCbx").addClass("checked");
                $("#mailDomain").val("").attr("disabled", false).parent().removeClass("display-none");
                $("#mailServerSetupDesc").addClass("display-none");
                $("#updadeSetupOptionsDesc, #disconnectBtn1").addClass("display-none");
                $("#installbtn").removeClass("display-none");
            }
        }
        
        $(".progress-block .progress-row").removeClass("odd even");
        $(".progress-block .progress-row:not(.display-none)").each(function (index, obj) {
            if (index % 2 == 0) {
                $(obj).addClass("even");
            } else {
                $(obj).addClass("odd");
            }
        });

        if (SetupInfo.installationProgress) {
            $("#setupFormDesc .description").addClass("display-none");
            $("#setupFormDesc .progress").removeClass("display-none");
        } else {
            $("#setupFormDesc .description").removeClass("display-none");
            $("#setupFormDesc .progress").addClass("display-none");
        }
    }

    function authTypeChange(obj) {
        if (obj.attr("id") == "passwordType") {
            $("#password").parent().removeClass("display-none");
            $("#sshKey").parent().addClass("display-none");
        } else {
            $("#password").parent().addClass("display-none");
            $("#sshKey").parent().removeClass("display-none");
        }

        checkConnectBtnEnabled();
    }

    function mailServerChange(obj) {
        if (obj.hasClass("checked")) {
            $("#mailDomain").parent().removeClass("display-none");
            $("#mailServerSetupDesc").addClass("display-none");
        } else {
            $("#mailDomain").parent().addClass("display-none");
            $("#mailServerSetupDesc").removeClass("display-none");
        }
    }

    function getConnectionSettings() {
        var usePassword = $("#passwordType").hasClass("checked");

        var settings = {
            host: $("#host").val().trim(),
            userName: $("#userName").val().trim(),
            password: usePassword ? $("#password").val().trim() : "",
            sshKey: usePassword ? "" : $("#sshKey").val().trim()
        };

        if (!settings.host) return null;

        if (!settings.userName) return null;
        
        if (usePassword && !settings.password) return null;

        if (!usePassword && !settings.sshKey) return null;

        return settings;
    }

    function getSelectedComponents() {

        if (SetupInfo.installedComponents) return null;

        var components = {
            communityServer: $("#installCommunityServerCbx").hasClass("checked"),
            documentServer: $("#installDocumentServerCbx").hasClass("checked"),
            mailServer: $("#installMailServerCbx").hasClass("checked"),
            mailDomain: $("#mailDomain").val().trim()
        };

        components.isEmpty = !components.communityServer && !components.documentServer && !components.mailServer;

        if (components.isEmpty) return null;

        if (components.mailServer && !components.mailDomain) return null;

        return components;
    }
    
    function getNotifyEmail() {
        var email = $("#email").val().trim();

        return email ? email : null;
    }

    function connectServer (settings) {

        $.ajax({
            url: connectUrl,
            type: "POST",
            data: JSON.stringify({
                connectionSettings: settings
            }),
            contentType: 'application/json; charset=utf-8',
            beforeSend: function () {
                Common.loader.show($("#connectionFieldsForm"));
                lockForm(true);
            },
            error: function () {
                $("#connectionErrorPop .error-message").text("").hide();
                $("#connectionErrorPop .default-message").show();
                Common.blockUI.show("connectionErrorPop");
                lockForm(false);
            },
            success: function (data) {
                if (data.success) {
                    SetupInfo.connectionSettings = JSON.parse(data.connectionSettings);
                    SetupInfo.installedComponents = JSON.parse(data.installedComponents);
                    SetupInfo.installationProgress = JSON.parse(data.installationProgress);
                    SetupInfo.selectedComponents = JSON.parse(data.selectedComponents);

                    var targetForm = getTargetForm();
                    displayForm(targetForm);
                    
                    if (installationIsPerformed()) {
                        lockForm(true);
                        checkInstallProgress();
                    }
                } else {
                    var message = window.OneClickJsResource["ErrorInstallation" + data.errorCode];
                    if (message) {
                        $("#connectionErrorPop .error-message").text(message).show();
                        $("#connectionErrorPop .default-message").hide();
                    } else {
                        $("#connectionErrorPop .error-message").text("").hide();
                        $("#connectionErrorPop .default-message").show();
                    }
                    Common.blockUI.show("connectionErrorPop");
                    lockForm(false);
                }
            },
            complete: function () {
                Common.loader.hide($("#connectionFieldsForm"));
            }
        });
    }

    function startInstall(settings, components) {

        if (components.mailServer && components.mailDomain) {
            var regex = new RegExp(/(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-zA-Z]{2,})$)/);
            if (!regex.test(components.mailDomain)) {
                $("#installErrorPop .error-message").text(window.OneClickJsResource.ErrorInvalidDomainName).show();
                $("#installErrorPop .default-message").hide();
                Common.blockUI.show("installErrorPop");
                return;
            }
        }

        $.ajax({
            url: startInstallUrl,
            type: "POST",
            data: JSON.stringify({
                connectionSettings: settings,
                installationComponents: components
            }),
            contentType: 'application/json; charset=utf-8',
            beforeSend: function () {
                lockForm(true);
                SetupInfo.selectedComponents = null;
                SetupInfo.installationProgress = null;
            },
            error: function (error) {
                toastr.error(error.message);
                lockForm(false);
            },
            success: function (data) {
                if (data.success) {
                    SetupInfo.selectedComponents = JSON.parse(data.selectedComponents);
                    SetupInfo.installationProgress = JSON.parse(data.installationProgress);
                    checkInstallProgress();
                } else {
                    $("#installErrorPop .error-message").html("").hide();
                    $("#installErrorPop .default-message").show();
                    Common.blockUI.show("installErrorPop");
                    lockForm(false);
                }
            }
        });
    }

    function checkInstallProgress () {

        $.ajax({
            url: installProgressUrl,
            type: "GET",
            contentType: 'application/json; charset=utf-8',
            beforeSend: function () {
                $(".progress-block .progress-row").removeClass("disabled");
                
                if (SetupInfo.selectedComponents) {
                    if (!SetupInfo.selectedComponents.documentServer){
                        $(".progress-block .progress-row[data-step=" + InstallationProgressStep.InstallDocumentServer + "]").addClass("disabled");
                        $("#installDocumentServerCbx").removeClass("checked");
                    }
                    if (!SetupInfo.selectedComponents.mailServer){
                        $(".progress-block .progress-row[data-step=" + InstallationProgressStep.InstallMailServer + "]").addClass("disabled");
                        $("#installMailServerCbx").removeClass("checked");
                        $("#mailDomain").val("").parent().addClass("display-none");
                    } else {
                        $("#mailDomain").val(SetupInfo.selectedComponents.mailDomain || "");
                    }
                    if (!SetupInfo.selectedComponents.communityServer) {
                        $(".progress-block .progress-row[data-step=" + InstallationProgressStep.InstallCommunityServer + "]").addClass("disabled");
                        $("#installCommunityServerCbx").removeClass("checked");
                    }
                }
            },
            error: function (error) {
                toastr.error(error.message);
                lockForm(false);
                $("#setupFormDesc .description").removeClass("display-none");
                $("#setupFormDesc .progress").addClass("display-none");
                SetupInfo.selectedComponents = null;
                SetupInfo.installationProgress = null;
            },
            success: function (data) {
                SetupInfo.installationProgress = data;
                if (data.success) {
                    $(".progress-block .progress-row:not(.disabled)").removeClass("done process error").each(function (index, obj) {
                        if ($(obj).attr("data-step") < data.step) {
                            if ($(obj).attr("data-step") == InstallationProgressStep.InstallDocker && data.step == InstallationProgressStep.RebootServer)
                                $(obj).addClass("process").find(".progress-desc").text(window.OneClickJsResource.InstallationStepRebootMsg);
                            else
                                $(obj).addClass("done").find(".progress-desc").text(window.OneClickJsResource.InstallationStepDoneMsg);
                        } else if ($(obj).attr("data-step") == data.step) {
                            $(obj).addClass("process").find(".progress-desc").text(window.OneClickJsResource.InstallationStepProcessMsg);
                        } else {
                            $(obj).find(".progress-desc").text("");
                        }
                    });
                    $("#setupFormDesc .description").addClass("display-none");
                    $("#setupFormDesc .progress").removeClass("display-none");
                    if (data.isCompleted) {
                        SetupInfo.installedComponents = JSON.parse(data.installedComponents);
                        setGoogleAnalytics();
                        displayForm(installForms.settingsForm);
                        SetupInfo.selectedComponents = null;
                        SetupInfo.installationProgress = null;
                    } else {
                        setTimeout(checkInstallProgress, 1000);
                    }
                } else {
                    $(".progress-block .progress-row.process").removeClass("process").addClass("error").find(".progress-desc").text(window.OneClickJsResource.InstallationStepErrorMsg);
                    var message = window.OneClickJsResource["ErrorInstallation" + data.errorCode];
                    if (message) {
                        $("#installErrorPop .error-message").text(message).show();
                        $("#installErrorPop .default-message").hide();
                    } else {
                        $("#installErrorPop .error-message").text("").hide();
                        $("#installErrorPop .default-message").show();
                    }
                    Common.blockUI.show("installErrorPop");
                    lockForm(false);
                    SetupInfo.selectedComponents = null;
                    SetupInfo.installationProgress = null;
                }
            }
        });
    }

    function sendEmail(email) {
        $.ajax({
            url: sendEmailUrl,
            type: "POST",
            data: JSON.stringify({
                email: email
            }),
            contentType: 'application/json; charset=utf-8',
            beforeSend: function () {
                Common.loader.show($("#notificationFieldsForm"));
                lockForm(true);
            },
            error: function (error) {
                toastr.error(error.message);
            },
            success: function (data) {
                if (data.success) {
                    $("#email").val("");
                    toastr.success(data.message);
                } else {
                    toastr.error(data.message);
                }
            },
            complete: function () {
                Common.loader.hide($("#notificationFieldsForm"));
                lockForm(false);
                checkConnectBtnEnabled();
            }
        });
    }

    function setGoogleAnalytics () {
        try {
            if (window.ga) {
                window.ga('send', 'event', 'button', 'install_successfully');
            }
        } catch (err) {
        }
    }

    return {
        init: init,
    };

})();