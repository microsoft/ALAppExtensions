namespace System.Security.AccessControl;

using Microsoft.Utility.ImageAnalysis;
using System.Security.AccessControl;

permissionsetextension 35981 "D365 BUS FULL ACCESSImage Analyzer" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "MS - Image Analyzer Tags" = RIMD,
                  tabledata "MS - Img. Analyzer Blacklist" = RIMD;
}
