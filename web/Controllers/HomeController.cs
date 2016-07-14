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
using System.Collections.Specialized;
using System.Globalization;
using System.IO;
using System.Net;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Mvc;
using ASC.Core.Billing;
using OneClickInstallation.Classes;
using OneClickInstallation.Helpers;
using OneClickInstallation.Models;
using OneClickInstallation.Resources;
using log4net;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace OneClickInstallation.Controllers
{
    public class HomeController : Controller
    {
        private string UserId
        {
            get
            {
                return CookieHelper.GetCookie();
            }
        }

        public ActionResult Index(string id)
        {
            var enterprise = !string.IsNullOrEmpty(id) && id.ToLowerInvariant() == "enterprise";

            ConnectionSettingsModel connectionSettings = null;
            InstallationComponentsModel availableComponents = CacheHelper.GetAvailableComponents(enterprise);
            InstallationComponentsModel installedComponents = null;
            InstallationComponentsModel selectedComponents = null;
            InstallationProgressModel installationProgress = null;
            OsInfo osInfo = null;

            if (!string.IsNullOrEmpty(UserId))
            {
                connectionSettings = CacheHelper.GetConnectionSettings(UserId);

                if (connectionSettings != null)
                {
                    installedComponents = CacheHelper.GetInstalledComponents(UserId);
                    selectedComponents = CacheHelper.GetSelectedComponents(UserId);
                    installationProgress = CacheHelper.GetInstallationProgress(UserId);
                    osInfo = CacheHelper.GetOsInfo(UserId);
                }
                else
                {
                    CookieHelper.ClearCookie();
                    CacheHelper.ClearUserCache(UserId);
                }
            }

            ViewBag.ConnectionSettings = GetJsonString(connectionSettings);
            ViewBag.AvailableComponents = GetJsonString(availableComponents);
            ViewBag.InstalledComponents = GetJsonString(installedComponents);
            ViewBag.SelectedComponents = GetJsonString(selectedComponents);
            ViewBag.InstallationProgress = GetJsonString(installationProgress);
            ViewBag.OsInfo = GetJsonString(osInfo);
            ViewBag.Enterprise = enterprise;
            ViewBag.EnterpriseLicenseRequired = Settings.EnterpriseLicenseRequired;

            if (!string.IsNullOrEmpty(Settings.CacheKey) && Request.Params["cache"] == Settings.CacheKey)
            {
                CacheHelper.ClearCache();
            }

            return View();
        }

        [HttpPost]
        public JsonResult UploadFile()
        {
            try
            {
                if (Request.Files == null || Request.Files.Count <= 0)
                    throw new Exception(OneClickCommonResource.ErrorFilesNotTransfered);

                var savedFileName = FileHelper.SaveFile(Request.Files[0]);

                bool isLicenseFile;

                if (Boolean.TryParse(Request.Params["license"], out isLicenseFile))
                {
                    if (isLicenseFile) ValidateLicenseFile(savedFileName);
                }

                return Json(new
                {
                    success = true,
                    message = OneClickCommonResource.FileUploadedMsg,
                    fileName = savedFileName
                });
            }
            catch (Exception ex)
            {
                LogManager.GetLogger("ASC").Error(ex.Message, ex);

                return Json(new
                {
                    success = false,
                    message = ex.Message,
                    fileName = string.Empty
                });
            }
        }

        [HttpPost]
        public JsonResult Connect(ConnectionSettingsModel connectionSettings, RequestInfoModel requestInfo)
        {
            try
            {
                InstallationComponentsModel installedComponents = null;
                InstallationComponentsModel selectedComponents = null;
                InstallationProgressModel installationProgress = null;
                OsInfo osInfo = null;

                if (connectionSettings != null)
                {
                    if (connectionSettings.Enterprise && Settings.EnterpriseLicenseRequired)
                    {
                        if (requestInfo == null && string.IsNullOrEmpty(connectionSettings.LicenseKey))
                            throw new Exception(OneClickCommonResource.ErrorRequestInfoIsNull);
                    }

                    var data = SshHelper.Connect(UserId, connectionSettings);

                    osInfo = data.Item1;
                    installedComponents = data.Item2;
                    installationProgress = CacheHelper.GetInstallationProgress(UserId);
                    selectedComponents = CacheHelper.GetSelectedComponents(UserId);

                    CacheHelper.SetConnectionSettings(UserId, connectionSettings);
                    CacheHelper.SetInstalledComponents(UserId, installedComponents);
                    CacheHelper.SetRequestInfo(UserId, requestInfo);
                }
                else
                {
                    CookieHelper.ClearCookie();
                    CacheHelper.ClearUserCache(UserId);
                }

                return Json(new
                    {
                        success = true,
                        message = string.Empty,
                        connectionSettings = GetJsonString(connectionSettings),
                        installedComponents = GetJsonString(installedComponents),
                        installationProgress = GetJsonString(installationProgress),
                        selectedComponents = GetJsonString(selectedComponents),
                        osInfo = GetJsonString(osInfo)
                    });
            }
            catch (Exception ex)
            {
                LogManager.GetLogger("ASC").Error(ex.Message, ex);

                return Json(new
                    {
                        success = false,
                        message = ex.Message,
                        errorCode = GetErrorCode(ex.Message)
                    });
            }
        }

        [HttpPost]
        public JsonResult StartInstall(InstallationComponentsModel installationComponents)
        {
            try
            {
                var connectionSettings = CacheHelper.GetConnectionSettings(UserId);
                var installedComponents = CacheHelper.GetInstalledComponents(UserId);
                var requestInfo = CacheHelper.GetRequestInfo(UserId);

                if (connectionSettings.Enterprise &&
                    Settings.EnterpriseLicenseRequired &&
                    string.IsNullOrEmpty(connectionSettings.LicenseKey) &&
                    requestInfo != null &&
                    !string.IsNullOrEmpty(Settings.LicenseUrl))
                {
                    connectionSettings = RequestLicenseFile(connectionSettings, requestInfo);
                }

                var mailServerAlreadyInstalled = installedComponents != null &&
                                                 !string.IsNullOrEmpty(installedComponents.MailServerVersion);

                if (!mailServerAlreadyInstalled && !string.IsNullOrEmpty(installationComponents.MailServerVersion) &&
                    !ValidateDomainName(installationComponents.MailDomain))
                    return Json(new
                        {
                            success = false,
                            message = OneClickJsResource.ErrorInvalidDomainName
                        });

                CacheHelper.SetSelectedComponents(UserId, installationComponents);

                CacheHelper.SetInstallationProgress(UserId, new InstallationProgressModel());

                SshHelper.StartInstallation(UserId, connectionSettings, installationComponents);

                return Json(new
                    {
                        success = true,
                        message = string.Empty,
                        selectedComponents = GetJsonString(CacheHelper.GetSelectedComponents(UserId)),
                        installationProgress = GetJsonString(CacheHelper.GetInstallationProgress(UserId))
                    });
            }
            catch (Exception ex)
            {
                LogManager.GetLogger("ASC").Error(ex.Message, ex);

                CacheHelper.SetSelectedComponents(UserId, null);
                CacheHelper.SetInstallationProgress(UserId, null);

                var code = 0;

                if (ex is ExternalException)
                {
                    Int32.TryParse(Regex.Match(ex.Message, @"[\d+]").Value, out code);
                }

                return Json(new
                    {
                        success = false,
                        message = ex.Message,
                        errorCode = code > 0 ? "External" + code : "unknown"
                    });
            }
        }

        [HttpGet]
        public JsonResult InstallProgress()
        {
            var progress = CacheHelper.GetInstallationProgress(UserId) ?? new InstallationProgressModel
                {
                    IsCompleted = true,
                    ErrorMessage = OneClickCommonResource.ErrorProgressIsNull
                };

            try
            {
                if (string.IsNullOrEmpty(progress.ErrorMessage))
                {
                    if (progress.IsCompleted)
                    {
                        CacheHelper.SetSelectedComponents(UserId, null);
                        CacheHelper.SetInstallationProgress(UserId, null);
                    }

                    return Json(new
                    {
                        success = true,
                        isCompleted = progress.IsCompleted,
                        step = (int)progress.Step,
                        errorCode = 0,
                        errorMessage = string.Empty,
                        progressText = Settings.DebugMode ? progress.ProgressText : string.Empty,
                        installedComponents = GetJsonString(progress.IsCompleted ? CacheHelper.GetInstalledComponents(UserId) : null)
                    }, JsonRequestBehavior.AllowGet);
                }

                CacheHelper.SetSelectedComponents(UserId, null);
                CacheHelper.SetInstallationProgress(UserId, null);

                return Json(new
                    {
                        success = false,
                        isCompleted = true,
                        step = (int)progress.Step,
                        errorCode = GetErrorCode(progress.ErrorMessage),
                        errorMessage = progress.ErrorMessage,
                        progressText = progress.ProgressText,
                        installedComponents = GetJsonString(CacheHelper.GetInstalledComponents(UserId))
                    }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                LogManager.GetLogger("ASC").Error(ex.Message, ex);

                CacheHelper.SetSelectedComponents(UserId, null);
                CacheHelper.SetInstallationProgress(UserId, null);

                return Json(new
                {
                    success = false,
                    isCompleted = true,
                    step = (int)progress.Step,
                    errorCode = 0,
                    errorMessage = ex.Message,
                    progressText = progress.ProgressText,
                    installedComponents = GetJsonString(CacheHelper.GetInstalledComponents(UserId))
                }, JsonRequestBehavior.AllowGet);
            }
        }


        private string GetJsonString(object obj)
        {
            var jsonString = JsonConvert.SerializeObject(
                obj,
                Formatting.None,
                new JsonSerializerSettings
                {
                    ContractResolver = new CamelCasePropertyNamesContractResolver()
                });

            return jsonString;
        }

        private int GetErrorCode(string errorMessage)
        {
            var errorCode = 0;
            var errorPattern = string.Format(@"{0}\[\d+\]", Settings.InstallationErrorPattern);
            var errorPatternValue = Regex.Match(errorMessage, errorPattern).Value;

            if (!string.IsNullOrEmpty(errorPatternValue))
            {
                var errorCodeStr = Regex.Match(errorPatternValue, @"\d+").Value;
                int.TryParse(errorCodeStr, out errorCode);
            }

            return errorCode;
        }

        private bool ValidateDomainName(string domainName)
        {
            if (string.IsNullOrEmpty(domainName)) return false;

            var regex = new Regex(@"(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-zA-Z]{2,})$)", RegexOptions.Compiled | RegexOptions.IgnoreCase);
            return regex.IsMatch(domainName);
        }

        private void ValidateLicenseFile(string fileName)
        {
            var filePath = FileHelper.GetFile(fileName);

            var ext = Path.GetExtension(filePath);

            if (string.IsNullOrEmpty(ext) || ext.ToLower() != ".lic")
            {
                FileHelper.RemoveFile(filePath);
                throw new Exception(OneClickCommonResource.ErrorFileExt);
            }

            //TODO: LicenseReader.CheckValid new .dll

            //if (LicenseReader.CheckValid(filePath)) return;

            //FileHelper.RemoveFile(filePath);
            //throw new Exception(OneClickCommonResource.ErrorLicenseFileNotValid);
        }

        private ConnectionSettingsModel RequestLicenseFile(ConnectionSettingsModel connectionSettings, RequestInfoModel requestInfo)
        {
            using (var client = new WebClient())
            {
                var values = new NameValueCollection();

                values["Host"] = connectionSettings.Host;
                values["FName"] = requestInfo.Name;
                values["Email"] = requestInfo.Email;
                values["Phone"] = requestInfo.Phone;
                values["CompanyName"] = requestInfo.CompanyName;
                values["CompanySize"] = requestInfo.CompanySize.ToString(CultureInfo.InvariantCulture);
                values["Position"] = requestInfo.Position;

                var response = client.UploadValues(Settings.LicenseUrl, values);

                var responseString = Encoding.Default.GetString(response).Replace("\"", string.Empty);

                if(responseString.Contains("error"))
                    throw new ExternalException(responseString);

                var licenseFileName = FileHelper.SaveFile(responseString);

                connectionSettings.LicenseKey = licenseFileName;

                CacheHelper.SetConnectionSettings(UserId, connectionSettings);

                return connectionSettings;
            }
        }
    }
}