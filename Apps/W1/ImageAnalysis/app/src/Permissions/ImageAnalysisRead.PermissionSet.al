permissionset 4212 "ImageAnalysis - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'Image Analyzer - Read';

    IncludedPermissionSets = "ImageAnalysis - Objects";

    Permissions = tabledata "MS - Image Analyzer Tags" = R,
                    tabledata "MS - Img. Analyzer Blacklist" = R;
}
