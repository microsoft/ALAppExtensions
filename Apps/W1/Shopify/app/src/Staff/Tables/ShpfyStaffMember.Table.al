// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.CRM.Team;

/// <summary>
/// Table Shpfy Staff Member (ID 30136).
/// </summary>
table 30136 "Shpfy Staff Member"
{
    Caption = 'Shopify Staff Member';
    DataClassification = CustomerContent;
    LookupPageId = "Shpfy Staff Mapping";
    DrillDownPageId = "Shpfy Staff Mapping";

    fields
    {
        field(1; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            Editable = false;
            TableRelation = "Shpfy Shop";
        }
        field(2; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Account Type"; Enum "Shpfy Staff Account Type")
        {
            Caption = 'Account Type';
            ToolTip = 'Specifies the staff account type.';
            Editable = false;
        }
        field(4; Active; Boolean)
        {
            Caption = 'Active';
            ToolTip = 'Specifies if the staff member is active.';
            Editable = false;
        }
        field(5; "Email"; Text[100])
        {
            Caption = 'Email';
            ToolTip = 'Specifies the staff member''s email address.';
            Editable = false;
        }
        field(6; Exists; Boolean)
        {
            Caption = 'Exists';
            ToolTip = 'Specifies if the staff member exists.';
            Editable = false;
        }
        field(7; "First Name"; Text[100])
        {
            Caption = 'First Name';
            ToolTip = 'Specifies the staff member''s first name.';
            Editable = false;
        }
        field(8; Initials; Text[10])
        {
            Caption = 'Initials';
            ToolTip = 'Specifies the staff member''s initials.';
            Editable = false;
        }
        field(9; "Shop Owner"; Boolean)
        {
            Caption = 'Shop Owner';
            ToolTip = 'Specifies if the staff member is the shop owner.';
            Editable = false;
        }
        field(10; "Last Name"; Text[100])
        {
            Caption = 'Last Name';
            ToolTip = 'Specifies the staff member''s last name.';
            Editable = false;
        }
        field(11; Locale; Text[5])
        {
            Caption = 'Locale';
            ToolTip = 'Specifies the staff member''s locale.';
            Editable = false;
        }
        field(12; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the staff member''s name.';
            Editable = false;
        }
        field(13; Phone; Text[20])
        {
            Caption = 'Phone';
            ToolTip = 'Specifies the staff member''s phone number.';
            Editable = false;
        }
        field(14; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            ToolTip = 'Specifies the sales person or purchaser code.';
            TableRelation = "Salesperson/Purchaser" where(Blocked = const(false));

            trigger OnValidate()
            var
                SalespersonPurchaser: Record "Salesperson/Purchaser";
                StaffMember: Record "Shpfy Staff Member";
                SalespersonPurchaserMappingErr: Label '%1 %2 already mapped to Shopify Staff Member %3.', Comment = '%1 = Salesperson/Purchaser table caption, %2 = Salesperson/Purchaser code, %3 = Shopify Staff Member name';
            begin
                if "Salesperson Code" <> '' then begin
                    SalespersonPurchaser.Get("Salesperson Code");
                    if SalespersonPurchaser.VerifySalesPersonPurchaserPrivacyBlocked(SalespersonPurchaser) then
                        Error(ErrorInfo.Create(SalespersonPurchaser.GetPrivacyBlockedGenericText(SalespersonPurchaser, true), true, SalespersonPurchaser));
                    StaffMember.SetRange("Shop Code", "Shop Code");
                    StaffMember.SetFilter(Id, '<>%1', Id);
                    StaffMember.SetRange("Salesperson Code", "Salesperson Code");
                    if StaffMember.FindFirst() then
                        Error(SalespersonPurchaserMappingErr, SalespersonPurchaser.TableCaption(), "Salesperson Code", StaffMember.Name);
                end;
            end;
        }
    }

    keys
    {
        key(PK; "Shop Code", Id)
        {
            Clustered = true;
        }
    }
}