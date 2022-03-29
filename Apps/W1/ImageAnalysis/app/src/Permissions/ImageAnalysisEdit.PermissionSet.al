permissionset 4210 "ImageAnalysis - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'Image Analyzer - Edit';

    IncludedPermissionSets = "ImageAnalysis - Read";

    Permissions = tabledata "MS - Image Analyzer Tags" = IMD,
                    tabledata "MS - Img. Analyzer Blacklist" = IMD;
}
