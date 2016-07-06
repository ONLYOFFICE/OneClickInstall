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

using System;
using System.Globalization;
using System.Reflection;
using System.Threading;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Optimization;
using OneClickInstallation.Helpers;
using TMResourceData;
using log4net.Config;

namespace OneClickInstallation
{
    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            XmlConfigurator.Configure();
            AreaRegistration.RegisterAllAreas();
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            InitializeDbResources();
        }

        private static void InitializeDbResources()
        {
            if (!Settings.ResourcesFromDataBase) return;

            DBResourceManager.PatchAssemblies();
            DBResourceManager.PatchAssembly(Assembly.GetExecutingAssembly(), false);
        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {
            var httpContext = Request.RequestContext.HttpContext;
            var routeData = httpContext != null ? RouteTable.Routes.GetRouteData(httpContext) : null;

            if (routeData == null)
                return;

            var routeLanguage = routeData.Values["lang"] != null ? routeData.Values["lang"].ToString() : null;

            if (string.IsNullOrEmpty(routeLanguage))
                return;

            if (routeLanguage == LangHelper.DefaultLanguage)
                Response.RedirectToRoutePermanent("Default", new
                {
                    controller = routeData.Values["controller"].ToString(),
                    action = routeData.Values["action"].ToString(),
                    id = routeData.Values["id"].ToString(),
                });
        }

        protected void Application_AcquireRequestState(object sender, EventArgs e)
        {
            var handler = Context.Handler as MvcHandler;
            var routeData = handler != null ? handler.RequestContext.RouteData : null;
            var routeLanguage = routeData != null && routeData.Values["lang"] != null ? routeData.Values["lang"].ToString() : null;
            var cultureInfo = CultureInfo.CreateSpecificCulture(!string.IsNullOrEmpty(routeLanguage) ? routeLanguage : LangHelper.DefaultLanguage);

            if (!Equals(Thread.CurrentThread.CurrentCulture, cultureInfo))
                Thread.CurrentThread.CurrentCulture = cultureInfo;

            if (!Equals(Thread.CurrentThread.CurrentUICulture, cultureInfo))
                Thread.CurrentThread.CurrentUICulture = cultureInfo;
        }
    }
}