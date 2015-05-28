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
using System.IO;
using System.Web;
using OneClickInstallation.Models;
using OneClickInstallation.Resources;

namespace OneClickInstallation.Helpers
{
    public class FileHelper
    {
        private const string DataFolder = "~/App_Data/";

        public static string SaveFile(string userId, HttpPostedFileBase file)
        {
            if (file == null)
                throw new Exception(OneClickCommonResource.ErrorFileIsNull);

            if (file.ContentLength <= 0 || Settings.MaxFileSize < file.ContentLength)
                throw new Exception(OneClickCommonResource.ErrorFileSize);

            var fileName = Path.GetFileName(file.FileName);

            if (fileName == null)
                throw new Exception(OneClickCommonResource.ErrorFileIsNull);

            var folderPath = HttpContext.Current.Server.MapPath(DataFolder + userId);

            if (!Directory.Exists(folderPath))
                Directory.CreateDirectory(folderPath);

            file.SaveAs(Path.Combine(folderPath, fileName));

            return fileName;
        }

        public static string GetFile(string userId, string fileName)
        {
            var filePath = Path.Combine(HttpContext.Current.Server.MapPath(DataFolder + userId), fileName);

            if (File.Exists(filePath))
            {
                return filePath;
            }

            throw new Exception(OneClickCommonResource.ErrorFileNotFound);
        }

        public static void CreateLogFile(string userId, InstallationProgressModel progressModel)
        {
            var fileName = "InstallSuccess.log";
            var content = progressModel.ProgressText;

            if (!string.IsNullOrEmpty(progressModel.ErrorMessage))
            {
                fileName = "InstallError.log";
                content = progressModel.ErrorMessage;
            }

            var filePath = Path.Combine(HttpContext.Current.Server.MapPath(DataFolder + userId),  fileName);

            using (var sw = new StreamWriter(filePath, true))
            {
                sw.WriteLine();
                sw.WriteLine(DateTime.Now.ToLongDateString());
                sw.WriteLine(DateTime.Now.ToLongTimeString());
                sw.Write(content);
                sw.Close();
            }
        }
    }
}