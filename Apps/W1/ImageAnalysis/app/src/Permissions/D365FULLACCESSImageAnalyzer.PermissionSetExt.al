namespace System.Security.AccessControl;

using Microsoft.Utility.ImageAnalysis;

permissionsetextension 42789 "D365 FULL ACCESSImage Analyzer" extends "D365 FULL ACCESS"
{
    Permissions = tabledata "MS - Image Analyzer Tags" = RIMD,
                  tabledata "MS - Img. Analyzer Blacklist" = RIMD;
}
