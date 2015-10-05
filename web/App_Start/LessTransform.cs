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

using System.IO;
using System.Web.Hosting;
using System.Web.Optimization;
using dotless.Core;
using dotless.Core.Input;
using dotless.Core.configuration;

namespace OneClickInstallation
{
    public class LessTransform : IBundleTransform
    {
        public void Process(BundleContext context, BundleResponse response)
        {
            var config = new DotlessConfiguration
                {
                    MinifyOutput = true,
                    ImportAllFilesAsLess = true,
                    CacheEnabled = true,
                    LessSource = typeof (VirtualFileReader)
                };

            response.Content = Less.Parse(response.Content, config);
            response.ContentType = "text/css"; 
        }
    }

    internal sealed class VirtualFileReader : IFileReader
    {
        public byte[] GetBinaryFileContents(string fileName)
        {
            fileName = GetFullPath(fileName);
            return File.ReadAllBytes(fileName);
        }

        public string GetFileContents(string fileName)
        {
            fileName = GetFullPath(fileName);
            return File.ReadAllText(fileName);
        }

        public bool DoesFileExist(string fileName)
        {
            fileName = GetFullPath(fileName);
            return File.Exists(fileName);
        }

        private static string GetFullPath(string path)
        {
            return HostingEnvironment.MapPath("~/Content/" + path);
        }
    } 
}