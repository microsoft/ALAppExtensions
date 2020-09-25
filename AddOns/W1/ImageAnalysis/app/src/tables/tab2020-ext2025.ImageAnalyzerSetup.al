// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

tableextension 2025 "MS - Image Analyzer Setup" extends "Image Analysis Setup"
{
    fields
    {
        field(8; "Image-Based Attribute Recognition Enabled"; Boolean)
        {
            Caption = 'Enable Image Analyzer';
        }

        field(9; "Confidence Threshold"; Integer)
        {
            Caption = 'Confidence Score Threshold %';

            MinValue = 0;
            MaxValue = 100;
            InitValue = 80;
        }
    }

    trigger OnBeforeModify()
    var
        UserPermissions: Codeunit "User Permissions";
    begin
        if (rec."Image-Based Attribute Recognition Enabled" and not UserPermissions.IsSuper(UserSecurityId())) then
            Error(NotAdminErr);
    end;

    var
        NotAdminErr: Label 'To enable image analysis, you must be an administrator. Ensure that you are assigned the ''SUPER'' user permission set.';
}