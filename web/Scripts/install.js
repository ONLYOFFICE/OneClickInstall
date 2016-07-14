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

var ActionUrl = {
    UploadFile: null,
    Connect: null,
    StartInstall: null,
    InstallProgress: null
};

var SetupInfo = {
    connectionSettings: null,
    availableComponents: null,
    installedComponents: null,
    selectedComponents: null,
    installationProgress: null,
    osInfo: null,
    requestInfo: null,
    trialFileName: null,
    enterprise: false,
    enterpriseLicenseRequired: false,

    installationInTheProcess: function() {
        return this.selectedComponents && this.installationProgress && !this.installationProgress.isCompleted;
    }
};

var Enums = {
    Page: {
        Connection: 0,
        Setup: 1,
        Settings: 2
    },
    InstallProgressStep: {
        Start: 0,
        UploadFiles: 1,
        GetOsInfo: 2,
        CheckPorts: 3,
        InstallDocker: 4,
        InstallDocumentServer: 5,
        InstallMailServer: 6,
        InstallControlPanel: 7,
        InstallCommunityServer: 8,
        WarmUp: 9,
        End: 10
    }
};

var DisplayManager = (function () {

    function getCurrentPage() {
        if (!SetupInfo.connectionSettings)
            return Enums.Page.Connection;

        if (SetupInfo.installationInTheProcess())
            return Enums.Page.Setup;

        if (SetupInfo.installedComponents && SetupInfo.installedComponents.isFull)
            return Enums.Page.Settings;

        return Enums.Page.Setup;
    }

    function displayPage(page) {

        var targetPage = arguments.length > 0 && page != undefined ? page : getCurrentPage();

        displayPageComponents(targetPage);

        if (!SetupInfo.installationInTheProcess())
            lockForm(false);
        
        refreshPageComponents();
    }

    function lockForm(disable) {
        if (disable) {
            $("input").attr("disabled", true);
            $(".button, .custom-radio, .custom-checkbox").addClass("disabled");
        } else {
            $("input").attr("disabled", false);
            $(".button, .custom-radio").removeClass("disabled");
            $(".custom-checkbox:not(.installed)").removeClass("disabled");
        }
    }

    function displayPageComponents(page) {
        $(".switcher-container .switcher-btn").removeClass("disabled selected");
        $(".form ").addClass("display-none");
        $(".form-desc").addClass("display-none");

        switch (page) {
            case Enums.Page.Connection:
                $(".switcher-container .switcher-btn.connection").addClass("selected");
                $("#connectionForm").removeClass("display-none");
                $("#connectionFormDesc").removeClass("display-none");
                break;
            case Enums.Page.Setup:
                $(".switcher-container .switcher-btn.setup").addClass("selected");
                $("#setupForm").removeClass("display-none");
                $("#setupFormDesc").removeClass("display-none");
                break;
            case Enums.Page.Settings:
                $(".switcher-container .switcher-btn.settings").addClass("selected");
                $("#settingsForm").removeClass("display-none");
                $("#settingsFormDesc").removeClass("display-none");
                break;
        }

    }

    function refreshPageComponents() {

        if (SetupInfo.connectionSettings) {
            $(".connected").removeClass("display-none");
            $(".disconnected").addClass("display-none");

            if (SetupInfo.connectionSettings.password) {
                $("#passwordType").click();
            } else if (SetupInfo.connectionSettings.sshKey) {
                $("#keyType").click();
            }

            $("#enterOnlyofficeBtn").attr("href", "http://" + SetupInfo.connectionSettings.host);
        } else {
            $(".switcher-container .switcher-btn.setup").addClass("disabled");
            $(".connected").addClass("display-none");
            $(".disconnected").removeClass("display-none");
            $("input[type=text], input[type=password]").val("");
        }

        $("#setupForm .custom-checkbox").removeClass("checked installed").addClass("disabled");
        $("#mailDomain").val("").attr("disabled", false).parent().addClass("display-none");
        $("#installBtn").removeClass("display-none");

        if (SetupInfo.availableComponents) {
            if(SetupInfo.availableComponents.communityServerVersion)
                $("#installCommunityServerCbx").addClass("checked");

            if (SetupInfo.availableComponents.documentServerVersion)
                $("#installDocumentServerCbx").addClass("checked");

            if (SetupInfo.availableComponents.mailServerVersion)
                $("#installMailServerCbx").removeClass("disabled");

            if (SetupInfo.availableComponents.controlPanelVersion)
                $("#installControlPanelCbx").removeClass("disabled");
        }

        if (SetupInfo.installedComponents) {
            if (SetupInfo.installedComponents.communityServerVersion)
                $("#installCommunityServerCbx").addClass("checked installed disabled");

            if (SetupInfo.installedComponents.documentServerVersion)
                $("#installDocumentServerCbx").addClass("checked installed disabled");

            if (SetupInfo.installedComponents.mailServerVersion)
                $("#installMailServerCbx").addClass("checked installed disabled");

            if (SetupInfo.installedComponents.controlPanelVersion)
                $("#installControlPanelCbx").addClass("checked installed disabled");

            if (SetupInfo.installedComponents.isFull)
                $("#installBtn").addClass("display-none");
        } else {
            $(".switcher-container .switcher-btn.settings").addClass("disabled");
        }

        $(".progress-block .progress-row").removeClass("odd even");
        $(".progress-block .progress-row:not(.display-none)").each(function (index, obj) {
            if (index % 2 == 0) {
                $(obj).addClass("even");
            } else {
                $(obj).addClass("odd");
            }
        });

        if (SetupInfo.installationInTheProcess()) {
            lockForm(true);

            $("#setupFormDesc .description").addClass("display-none");
            $("#setupFormDesc .progress").removeClass("display-none");
            
            if (SetupInfo.selectedComponents.documentServerVersion)
                $("#installDocumentServerCbx").addClass("checked");

            if (SetupInfo.selectedComponents.mailServerVersion)
                $("#installMailServerCbx").addClass("checked");

            if (SetupInfo.selectedComponents.mailDomain)
                $("#mailDomain").val(SetupInfo.selectedComponents.mailDomain).parent().removeClass("display-none");

            if (SetupInfo.selectedComponents.communityServerVersion)
                $("#installCommunityServerCbx").addClass("checked");

            if (SetupInfo.selectedComponents.controlPanelVersion)
                $("#installControlPanelCbx").addClass("checked");

        } else {
            $("#setupFormDesc .description").removeClass("display-none");
            $("#setupFormDesc .progress").addClass("display-none");
        }
    }

    return {
        displayPage: displayPage,
        lockForm: lockForm,
    };

})();

var InstallManager = (function () {

    function init () {
        setBindings();
        refreshPageContent();
        
        if (SetupInfo.installationInTheProcess()) {
            DisplayManager.lockForm(true);
            checkInstallProgress();
        }
    }

    function setBindings() {
        Common.selectorListener.init();

        $("#sshFile").on("change", function () {
            fileChange(this, $("#sshKey"), false);
        });

        $("#licenseFile").on("change", function () {
            fileChange(this, $("#licenseKey"), true);
        });

        $(".switcher-container .switcher-btn").on("click", function () {
            pageChange($(this));
        });

        $(".custom-radio[data-name=authType]").on("click", function () {
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

        $("#disconnectBtn").on("click", function () {
            if ($(this).hasClass("disabled")) return;

            connectServer(null);
        });

        $("#installBtn").on("click", function () {
            if ($(this).hasClass("disabled")) return;

            if (SetupInfo.installedComponents && SetupInfo.installedComponents.isFull) {
                Common.blockUI.show("existVersionErrorPop");
                return;
            }

            var components = getSelectedComponents();

            if (components == null) return;

            startInstall(components);
        });

        $("#connectionForm input")
            .on("keyup", function (event) {
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
                    } else if ($(this).is("#sshKey") || $(this).is("#password")) {
                        if ($("#licenseKey").length)
                            $("#licenseKey").focus();
                        else
                            $("#connectBtn").click();
                    }
                    else if ($(this).is("#licenseKey")) {
                        $("#connectBtn").click();
                    }
                }
            })
            .on("change", function () {
                checkConnectBtnEnabled();
            });

        $("#mailDomain")
            .on("keyup", function () {
                checkInstallBtnEnabled();
            })
            .on("change", function () {
                checkInstallBtnEnabled();
            });

        $("#showTrialPop").on("click", function() {
            var popup = $("#trialPop");
            popup.find("input[type=text]").val("");
            popup.find(".disconnected").removeClass("display-none");
            popup.find(".connected ").addClass("display-none");
            $("#trialBtn").addClass("disabled");
            
            Common.blockUI.show("trialPop", 460, 630);
            
            $("#name").focus();
        });

        $("#trialPop input")
            .on("keyup", function (event) {
                checkTrialBtnEnabled();

                var code = Common.getKeyCode(event);

                if (code == 13) {
                    if ($(this).is("#name")) {
                        $("#email").focus();
                    } else if ($(this).is("#email")) {
                        $("#phone").focus();
                    } else if ($(this).is("#phone")) {
                        $("#companyName").focus();
                    } else if ($(this).is("#companyName")) {
                        $("#companySize").click();
                    } else if ($(this).is("#position")) {
                        $("#trialBtn").click();
                    }
                }
            })
            .on("change", function () {
                checkTrialBtnEnabled();
            });

        $("#trialBtn").on("click", function () {
            if ($(this).hasClass("disabled")) return;

            SetupInfo.requestInfo = getRequestInfo();
            
            if (!SetupInfo.requestInfo) return;

            $("#licenseKey").val(SetupInfo.trialFileName);
            checkConnectBtnEnabled();
            Common.blockUI.hide();
        });
    }

    function refreshPageContent(page) {
        
        DisplayManager.displayPage(page);

        checkConnectBtnEnabled();
        checkInstallBtnEnabled();
    }

    function checkConnectBtnEnabled() {
        var settings = getConnectionSettings();

        if (settings && !SetupInfo.installationInTheProcess()) {
            $("#connectBtn").removeClass("disabled");
        } else {
            $("#connectBtn").addClass("disabled");
        }
    }
    
    function checkInstallBtnEnabled() {
        var components = getSelectedComponents();

        if (components && !SetupInfo.installationInTheProcess() && $("#setupForm .custom-checkbox.checked:not(.installed)").length) {
            $("#installBtn").removeClass("disabled");
        } else {
            $("#installBtn").addClass("disabled");
        }
    }

    function checkTrialBtnEnabled() {
        var requestInfo = getRequestInfo();

        if (requestInfo) {
            $("#trialBtn").removeClass("disabled");
        } else {
            $("#trialBtn").addClass("disabled");
        }
    }

    function fileChange(inputFile, inputText, isLicense) {
        var formdata = new window.FormData();

        $.each(inputFile.files, function () {
            formdata.append(inputFile.name, this);
        });

        var urlParams = "";

        if (isLicense) {
            SetupInfo.requestInfo = null;
            urlParams = "?license=true";
        }

        $.ajax({
            url: ActionUrl.UploadFile + urlParams,
            type: "POST",
            data: formdata,
            dataType: 'json',
            contentType: false,
            processData: false,
            beforeSend: function () {
                Common.loader.show($("#connectionForm"));
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
                Common.loader.hide($("#connectionForm"));
                checkConnectBtnEnabled();
            }
        });

        return false;
    }
    
    function pageChange(obj) {
        if (obj.hasClass("disabled")) return;

        var page = null;

        if (obj.hasClass("connection"))
            page = Enums.Page.Connection;

        if (obj.hasClass("setup"))
            page = Enums.Page.Setup;

        if (obj.hasClass("settings"))
            page = Enums.Page.Settings;

        if (page == null) return;

        refreshPageContent(page);
    }

    function authTypeChange(obj) {
        if (obj.hasClass("disabled")) return;

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
        } else {
            $("#mailDomain").parent().addClass("display-none");
        }
    }

    function getConnectionSettings() {
        var usePassword = $("#passwordType").hasClass("checked");

        var settings = {
            host: $("#host").val().trim(),
            userName: $("#userName").val().trim(),
            password: usePassword ? $("#password").val().trim() : "",
            sshKey: usePassword ? "" : $("#sshKey").val().trim(),
            licenseKey: "",
            enterprise: SetupInfo.enterprise
        };

        if (!settings.host) return null;

        if (!settings.userName) return null;
        
        if (usePassword && !settings.password) return null;

        if (!usePassword && !settings.sshKey) return null;

        if (SetupInfo.enterprise && SetupInfo.enterpriseLicenseRequired) {
            if (!SetupInfo.requestInfo) {
                settings.licenseKey = $("#licenseKey").val().trim();
                if (!settings.licenseKey) return null;
            }
        }

        return settings;
    }

    function getSelectedComponents() {

        var components = {
            communityServerVersion: null,
            documentServerVersion: null,
            mailServerVersion: null,
            mailDomain: $("#mailDomain").val().trim(),
            controlPanelVersion: null
        };

        if (SetupInfo.installedComponents) {
            components.communityServerVersion = SetupInfo.installedComponents.communityServerVersion;
            components.documentServerVersion = SetupInfo.installedComponents.documentServerVersion;
            components.mailServerVersion = SetupInfo.installedComponents.mailServerVersion;

            if(SetupInfo.enterprise)
                components.controlPanelVersion = SetupInfo.installedComponents.controlPanelVersion;
        }

        if ($("#installCommunityServerCbx").hasClass("checked") && !components.communityServerVersion) {
            components.communityServerVersion = SetupInfo.availableComponents.communityServerVersion;
        }
        
        if ($("#installDocumentServerCbx").hasClass("checked") && !components.documentServerVersion) {
            components.documentServerVersion = SetupInfo.availableComponents.documentServerVersion;
        }

        if ($("#installMailServerCbx").hasClass("checked") && !components.mailServerVersion) {
            components.mailServerVersion = SetupInfo.availableComponents.mailServerVersion;
        }
        
        if (SetupInfo.enterprise && $("#installControlPanelCbx").hasClass("checked") && !components.controlPanelVersion) {
            components.controlPanelVersion = SetupInfo.availableComponents.controlPanelVersion;
        }

        components.isEmpty = !components.communityServerVersion && !components.documentServerVersion && !components.mailServerVersion;
        components.isFull = components.communityServerVersion && components.documentServerVersion && components.mailServerVersion;

        if (SetupInfo.enterprise) {
            components.isEmpty = components.isEmpty && !components.controlPanelVersion;
            components.isFull = components.isFull && components.controlPanelVersion;
        }

        if (components.isEmpty) return null;

        var mailServerAlreadyInstalled = SetupInfo.installedComponents && SetupInfo.installedComponents.mailServerVersion;

        if (!mailServerAlreadyInstalled && components.mailServerVersion && !components.mailDomain) return null;

        return components;
    }

    function getRequestInfo() {

        var requestInfo = {
            name: $("#name").val().trim(),
            email: $("#email").val().trim(),
            phone: $("#phone").val().trim(),
            companyName: $("#companyName").val().trim(),
            companySize: parseInt($("#companySize").parent().data("value")),
            position: $("#position").val().trim()
        };

        if (!requestInfo.name) return null;

        if (!requestInfo.email) return null;

        var regEx = /^([\w-\.\+]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,7}|[0-9]{1,3})(\]?)$/;

        if (!regEx.test(requestInfo.email)) return null;

        if (!requestInfo.phone) return null;

        if (!requestInfo.companyName) return null;

        if (!requestInfo.companySize) return null;

        if (!requestInfo.position) return null;

        return requestInfo;
    }

    function connectServer (settings) {

        $.ajax({
            url: ActionUrl.Connect,
            type: "POST",
            data: JSON.stringify({
                connectionSettings: settings,
                requestInfo: SetupInfo.requestInfo
            }),
            contentType: 'application/json; charset=utf-8',
            beforeSend: function () {
                Common.loader.show($("#connectionForm"));
                DisplayManager.lockForm(true);
            },
            error: function () {
                showConnectionErrorPop();
                DisplayManager.lockForm(false);
            },
            success: function (data) {
                if (data.success) {
                    SetupInfo.connectionSettings = JSON.parse(data.connectionSettings);
                    SetupInfo.installedComponents = JSON.parse(data.installedComponents);
                    SetupInfo.installationProgress = JSON.parse(data.installationProgress);
                    SetupInfo.selectedComponents = JSON.parse(data.selectedComponents);
                    SetupInfo.osInfo = JSON.parse(data.osInfo);

                    refreshPageContent();

                    if (SetupInfo.installationInTheProcess()) {
                        DisplayManager.lockForm(true);
                        checkInstallProgress();
                    }
                } else {
                    var message = window.OneClickJsResource["ErrorInstallation" + data.errorCode];
                    showConnectionErrorPop(message);
                    DisplayManager.lockForm(false);
                }
            },
            complete: function () {
                Common.loader.hide($("#connectionForm"));
            }
        });
    }

    function startInstall(components) {

        if (components.mailServerVersion && components.mailDomain) {
            var regex = new RegExp(/(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-zA-Z]{2,})$)/);
            if (!regex.test(components.mailDomain)) {
                showInstallErrorPop(window.OneClickJsResource.ErrorInvalidDomainName);
                return;
            }
        }

        $.ajax({
            url: ActionUrl.StartInstall,
            type: "POST",
            data: JSON.stringify({
                installationComponents: components
            }),
            contentType: 'application/json; charset=utf-8',
            beforeSend: function () {
                DisplayManager.lockForm(true);
                SetupInfo.selectedComponents = null;
                SetupInfo.installationProgress = null;
            },
            error: function (error) {
                toastr.error(error.message);
                DisplayManager.lockForm(false);
            },
            success: function (data) {
                if (data.success) {
                    SetupInfo.selectedComponents = JSON.parse(data.selectedComponents);
                    SetupInfo.installationProgress = JSON.parse(data.installationProgress);
                    checkInstallProgress();
                } else {
                    var message = window.OneClickJsResource["ErrorInstallation" + data.errorCode];
                    showInstallErrorPop(message);
                    DisplayManager.lockForm(false);
                }
            }
        });
    }

    function checkInstallProgress () {

        $.ajax({
            url: ActionUrl.InstallProgress,
            type: "GET",
            contentType: 'application/json; charset=utf-8',
            beforeSend: function () {
                prepareProgressBlock();
            },
            error: function (error) {
                toastr.error(error.message);
                DisplayManager.lockForm(false);
                $("#setupFormDesc .description").removeClass("display-none");
                $("#setupFormDesc .progress").addClass("display-none");
                SetupInfo.selectedComponents = null;
                SetupInfo.installationProgress = null;
            },
            success: function (data) {
                SetupInfo.installationProgress = data;

                if (data.isCompleted)
                    SetupInfo.installedComponents = JSON.parse(data.installedComponents);

                if (data.success) {
                    refreshProgressBlock(data.step);
                    $("#setupFormDesc .description").addClass("display-none");
                    $("#setupFormDesc .progress").removeClass("display-none");
                    if (data.isCompleted) {
                        setGoogleAnalytics();
                        refreshPageContent(Enums.Page.Settings);
                        SetupInfo.selectedComponents = null;
                        SetupInfo.installationProgress = null;
                    } else {
                        setTimeout(checkInstallProgress, 1000);
                    }
                } else {
                    $(".progress-block .progress-row.process").removeClass("process").addClass("error").find(".progress-desc").text(window.OneClickJsResource.InstallationStepErrorMsg);
                    var message = window.OneClickJsResource["ErrorInstallation" + data.errorCode];
                    showInstallErrorPop(message);
                    DisplayManager.lockForm(false);
                    SetupInfo.selectedComponents = null;
                    SetupInfo.installationProgress = null;
                }
            }
        });
    }

    function prepareProgressBlock() {
        $(".progress-block .progress-row").removeClass("disabled");

        if (SetupInfo.selectedComponents) {
            if (!SetupInfo.selectedComponents.documentServerVersion) {
                $(".progress-block .progress-row[data-step=" + Enums.InstallProgressStep.InstallDocumentServer + "]").addClass("disabled");
                $("#installDocumentServerCbx").removeClass("checked");
            }
            if (!SetupInfo.selectedComponents.mailServerVersion) {
                $(".progress-block .progress-row[data-step=" + Enums.InstallProgressStep.InstallMailServer + "]").addClass("disabled");
                $("#installMailServerCbx").removeClass("checked");
                $("#mailDomain").val("").parent().addClass("display-none");
            } else {
                $("#mailDomain").val(SetupInfo.selectedComponents.mailDomain || "");
            }
            if (!SetupInfo.selectedComponents.communityServerVersion) {
                $(".progress-block .progress-row[data-step=" + Enums.InstallProgressStep.InstallCommunityServer + "]").addClass("disabled");
                $("#installCommunityServerCbx").removeClass("checked");
            }
            if (!SetupInfo.selectedComponents.controlPanelVersion) {
                $(".progress-block .progress-row[data-step=" + Enums.InstallProgressStep.InstallControlPanel + "]").addClass("disabled");
                $("#installControlPanelCbx").removeClass("checked");
            }
        }
    }

    function refreshProgressBlock(progressStep) {
        $(".progress-block .progress-row:not(.disabled)").removeClass("done process error").each(function (index, obj) {
            if ($(obj).attr("data-step") < progressStep) {
                $(obj).addClass("done").find(".progress-desc").text(window.OneClickJsResource.InstallationStepDoneMsg);
            } else if ($(obj).attr("data-step") == progressStep) {
                $(obj).addClass("process").find(".progress-desc").text(window.OneClickJsResource.InstallationStepProcessMsg);
            } else {
                $(obj).find(".progress-desc").text("");
            }
        });
    }

    function showConnectionErrorPop(message) {
        if (message) {
            $("#connectionErrorPop .error-message").text(message).show();
            $("#connectionErrorPop .default-message").hide();
        } else {
            $("#connectionErrorPop .error-message").text("").hide();
            $("#connectionErrorPop .default-message").show();
        }
        Common.blockUI.show("connectionErrorPop");
    }

    function showInstallErrorPop(message) {
        if (message) {
            $("#installErrorPop .error-message").text(message).show();
            $("#installErrorPop .default-message").hide();
        } else {
            $("#installErrorPop .error-message").text("").hide();
            $("#installErrorPop .default-message").show();
        }
        Common.blockUI.show("installErrorPop");
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
        init: init
    };

})();