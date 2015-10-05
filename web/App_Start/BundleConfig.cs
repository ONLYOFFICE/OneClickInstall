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

using System.Web.Optimization;

namespace OneClickInstallation
{
    public class BundleConfig
    {
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js",
                        "~/Scripts/jquery.blockUI.js"));

            bundles.Add(new ScriptBundle("~/bundles/homepage").Include(
                        "~/Scripts/common.js",
                        "~/Scripts/toastr.js",
                        "~/Scripts/install.js"));

            bundles.Add(new Bundle("~/Content/less", new LessTransform(), new CssMinify()).Include(
                        "~/Content/vars.less",
                        "~/Content/layout.less",
                        "~/Content/header.less",
                        "~/Content/paragraph.less",
                        "~/Content/link.less",
                        "~/Content/list.less",
                        "~/Content/button.less",
                        "~/Content/form.less",
                        "~/Content/toastr.less",
                        "~/Content/action-menu.less",
                        "~/Content/lang-switcher.less",
                        "~/Content/site.less"));
        }
    }
}