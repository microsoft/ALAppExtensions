permissionset 4211 "ImageAnalysis - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Image Analyzer - Objects';

    Permissions = codeunit "Contact Picture Analyze" = X,
                     codeunit "Image Analyzer Ext. Mgt." = X,
                     codeunit "Image Analysis Install" = X,
                     codeunit "Item Attr Populate" = X,
                     page "Image Analysis Blacklist" = X,
                     page "Image Analyzer Wizard" = X,
                     page "Image Analysis Tags" = X,
                     table "MS - Image Analyzer Tags" = X,
                     table "MS - Img. Analyzer Blacklist" = X;
}