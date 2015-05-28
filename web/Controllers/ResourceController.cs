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
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Resources;
using System.Text;
using System.Web.Mvc;
using OneClickInstallation.Helpers;
using OneClickInstallation.Resources;
using TMResourceData;

namespace OneClickInstallation.Controllers
{
    public class ResourceController : Controller
    {

        public ActionResult Index(string culture)
        {
            if (string.IsNullOrWhiteSpace(culture))
            {
                culture = System.Threading.Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName;
            }

            if (!ClientCacheEmpty()) return NotModifiedResponse();

            var cachedScript = CacheHelper.GetJsResuorce(culture);

            if (cachedScript != null) return ScriptResponse(cachedScript);

            var resources = new List<Tuple<ResourceManager, string>>
                {
                    new Tuple<ResourceManager, string>(OneClickJsResource.ResourceManager, typeof (OneClickJsResource).Name)
                };

            var script = CreateResourcesScript(resources, culture);

            CacheHelper.SetJsResuorce(culture, script);

            return ScriptResponse(script);
        }


        private bool ClientCacheEmpty()
        {
            return (Request.Headers["If-Modified-Since"] == null);
        }

        private ContentResult NotModifiedResponse()
        {
            Response.StatusCode = 304;
            Response.StatusDescription = "Not Modified";
            return Content(string.Empty);
        }

        private JavaScriptResult ScriptResponse(string script)
        {
            Response.Cache.SetLastModified(DateTime.UtcNow);
            return new JavaScriptResult { Script = script };
        }

        private static string CreateResourcesScript(IEnumerable<Tuple<ResourceManager, string>> resources, string culture)
        {
            var script = string.Empty;
            foreach (var pair in resources)
            {
                var set = pair.Item1.GetResourceSet(new CultureInfo(culture), true, true);
                var baseSet = pair.Item1.GetResourceSet(new CultureInfo(LangHelper.DefaultLanguage), true, true);

                var dbManager = pair.Item1 as DBResourceManager;
                var baseNeutral = baseSet;

                if (dbManager != null)
                {
                    baseNeutral = dbManager.GetBaseNeutralResourceSet();
                }

                var js = new StringBuilder(pair.Item2 + "={");
                foreach (DictionaryEntry entry in baseNeutral)
                {
                    var value = set.GetString((string)entry.Key) ?? baseSet.GetString((string)entry.Key) ?? baseNeutral.GetString((string)entry.Key) ?? string.Empty;
                    js.AppendFormat("\"{0}\":\"{1}\",", entry.Key, (value).Replace("\"", "\\\""));
                }

                script += js.ToString();
                if (!string.IsNullOrEmpty(script))
                {
                    script = script.Remove(script.Length - 1);
                }
                script += "};";
            }

            return script;
        }
    }
}