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

String.prototype.format = function () {
    var txt = this,
        i = arguments.length;

    while (i--) {
        txt = txt.replace(new RegExp("\\{" + i + "\\}", "gm"), arguments[i]);
    }
    return txt;
};

if (typeof String.prototype.endsWith !== 'function') {
    String.prototype.endsWith = function (suffix) {
        return this.indexOf(suffix, this.length - suffix.length) !== -1;
    };
}

jQuery.fn.center = function(parent) {

    this.css("top", Math.max(0, (($(parent).height() - $(this).outerHeight()) / 2) + $(parent).scrollTop()) + "px");
    this.css("left", Math.max(0, (($(parent).width() - $(this).outerWidth()) / 2) + $(parent).scrollLeft()) + "px");

    return this;
};

$("body").on("click", function (event) {
    var target = (event.target) ? event.target : event.srcElement;
    var element = $(target);

    if (!element.is(".lang-switcher .switcher")) {
        $(".lang-switcher .action-menu").hide();
    }
});

$("body").on("click", ".lang-switcher .switcher", function () {
    $(".lang-switcher .action-menu").toggle();
    return false;
});

$(".popup .okbtn, .popup .cancelbtn, .popup .popup-close").on("click", function () {
    Common.blockUI.hide();
});

$(".custom-radio").on("click", function () {
    if ($(this).hasClass("disabled")) return;

    var dataName = $(this).attr("data-name");
    if (dataName) {
        $(".custom-radio[data-name={0}]".format(dataName)).removeClass("checked");
    }
    $(this).addClass("checked");
});

$(".custom-checkbox").on("click", function () {
    if ($(this).hasClass("disabled")) return;

    $(this).toggleClass("checked");
});

$(document).keyup(function (event) {
    var code = Common.getKeyCode(event);

    if (code == null) return;

    if (code == 27 && $(".blockUI").is(":visible")) {
        Common.blockUI.hide();
    }

    if (code == 13 && $(".blockUI .okbtn").is(":visible")) {
        Common.blockUI.hide();
    }
});

var Common = (function () {

    var loader = function () {

        return {
            show: function (obj) {
                $("#formLoaderBlock, #formLoader").remove();

                var html = '<div id="formLoaderBlock"></div><div id="formLoader">{0}</div>'
                    .format(window.OneClickJsResource.LoaderMsg);

                obj.addClass("loading").append(html);

                $("#formLoader").center(obj);
            },

            hide: function (obj) {
                obj.removeClass("loading");
                $("#formLoaderBlock, #formLoader").remove();
            }
        };
    }();

    var blockUI = function () {

        function block (obj, width, height, left, top) {
            try {
                width = parseInt(width || 0);
                height = parseInt(height || 0);
                left = parseInt(left || - width / 2);
                top = parseInt(top || -height / 2);
                $.blockUI({
                    message: $(obj),
                    css: {
                        left: "50%",
                        top: "50%",
                        opacity: "1",
                        border: "none",
                        padding: "0px",
                        width: width > 0 ? width + "px" : "auto",
                        height: height > 0 ? height + "px" : "auto",
                        cursor: "default",
                        textAlign: "left",
                        position: "fixed",
                        "margin-left": left + "px",
                        "margin-top": top + "px",
                        "background-color": "Transparent"
                    },

                    overlayCSS: {
                        backgroundColor: "#333",
                        cursor: "default",
                        opacity: "0.4"
                    },

                    focusInput: true,
                    baseZ: 666,

                    fadeIn: 0,
                    fadeOut: 0
                });
            } catch (e) {
            }
        }

        return {
            show: function (popupId, width, height, marginLeft, marginTop) {
                width = width || 362;
                height = height || 325;
                marginLeft = marginLeft || 0;
                marginTop = marginTop || 0;

                $(":focus").blur();

                block("#" + popupId, width, height, marginLeft, marginTop);
            },
            hide: function () {
                $.unblockUI();
            }
        };
    }();

    var getKeyCode = function(event) {
        var code = null;

        if (event.keyCode)
            code = event.keyCode;
        else if (event.which)
            code = event.which;

        return code;
    };

    return {
        loader: loader,
        blockUI: blockUI,
        getKeyCode: getKeyCode
    };
    
})($);