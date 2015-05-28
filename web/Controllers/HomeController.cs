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
using System.Net;
using System.Net.Mail;
using System.Text.RegularExpressions;
using System.Web.Mvc;
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
                return Regex.Replace(Request.UserHostAddress ?? string.Empty, "[^0-9-.a-zA-Z_=]", "_");
            }
        }

        public ActionResult Index()
        {
            var connectionSettings = CacheHelper.GetConnectionSettings(UserId);
            ViewBag.ConnectionSettings = GetJsonString(connectionSettings);

            var installedComponents = CacheHelper.GetInstalledComponents(UserId);
            ViewBag.InstalledComponents = GetJsonString(installedComponents);

            var selectedComponents = CacheHelper.GetSelectedComponents(UserId);
            ViewBag.SelectedComponents = GetJsonString(selectedComponents);

            var installationProgress = CacheHelper.GetInstallationProgress(UserId);
            ViewBag.InstallationProgress = GetJsonString(installationProgress);

            return View();
        }

        [HttpPost]
        public JsonResult UploadFile()
        {
            try
            {
                if (Request.Files.Count <= 0)
                {
                    throw new Exception(OneClickCommonResource.ErrorFilesNotTransfered);
                }

                return Json(new
                {
                    success = true,
                    message = OneClickCommonResource.FileUploadedMsg,
                    fileName = FileHelper.SaveFile(UserId, Request.Files[0])
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
        public JsonResult Connect(ConnectionSettingsModel connectionSettings)
        {
            try
            {
                InstallationComponentsModel installedComponents = null;
                
                if (connectionSettings != null)
                {
                    installedComponents = SshHelper.Connect(UserId, connectionSettings);
                }

                CacheHelper.SetConnectionSettings(UserId, connectionSettings);
                CacheHelper.SetInstalledComponents(UserId, installedComponents);

                return Json(new
                    {
                        success = true,
                        message = string.Empty,
                        connectionSettings = GetJsonString(connectionSettings),
                        installedComponents = GetJsonString(installedComponents)
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
        public JsonResult StartInstall(ConnectionSettingsModel connectionSettings, InstallationComponentsModel installationComponents)
        {
            try
            {
                var installedComponents = CacheHelper.GetInstalledComponents(UserId);

                if (installedComponents != null)
                    return Json(new
                        {
                            success = false,
                            message = OneClickHomePageResource.ExistVersionErrorText
                        });

                if (!installationComponents.CommunityServer || !installationComponents.DocumentServer)
                    return Json(new
                        {
                            success = false,
                            message = OneClickCommonResource.ErrorRequiredComponents
                        });

                if (installationComponents.MailServer && !ValidateDomainName(installationComponents.MailDomain))
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

                return Json(new
                    {
                        success = false,
                        message = ex.Message
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
                        installedComponents = GetJsonString(progress.IsCompleted ? CacheHelper.GetInstalledComponents(UserId) : null),
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
                        progressText = progress.ProgressText
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
                    progressText = progress.ProgressText
                }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult SendEmail(string email)
        {
            try
            {
                var targetEmail = new MailAddress(email);

                var emailSender = Settings.EmailSender;

                if(emailSender == null)
                    throw new Exception(OneClickCommonResource.EmailSenderIsNull);

                var mail = new MailMessage();

                var client = new SmtpClient
                    {
                        Host = emailSender.Host,
                        Port = emailSender.Port,
                        Timeout = 10000,
                        EnableSsl = true,
                        DeliveryMethod = SmtpDeliveryMethod.Network,
                        UseDefaultCredentials = false,
                        Credentials = new NetworkCredential(emailSender.Email.Split('@')[0], emailSender.Password)
                    };

                mail.To.Add(new MailAddress(Settings.SupportEmail));
                mail.From = new MailAddress(emailSender.Email);
                mail.Subject = OneClickJsResource.NotyfyEmailSubject;
                mail.Body = string.Format(OneClickJsResource.NotyfyEmailBody, targetEmail.Address);

                client.Send(mail);

                return Json(new
                    {
                        success = true,
                        message = OneClickJsResource.EmailSendedMsg,
                    });
            }
            catch (Exception ex)
            {
                LogManager.GetLogger("ASC").Error(ex.Message, ex);

                return Json(new
                    {
                        success = false,
                        message = ex.Message
                    });
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
    }
}