namespace Microsoft.Integration.Shopify;
using Microsoft.CRM.Team;

/// <summary>
/// Table Shpfy Staff Member (ID 30136).
/// </summary>
table 30136 "Shpfy Staff Member"
{
    Caption = 'Shopify Staff Member';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = CustomerContent;
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
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Email"; Text[100])
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; Exists; Boolean)
        {
            Caption = 'Exists';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "First Name"; Text[100])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; Initials; Text[10])
        {
            Caption = 'Initials';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Shop Owner"; Boolean)
        {
            Caption = 'Shop Owner';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Last Name"; Text[100])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; Locale; Text[5])
        {
            Caption = 'Locale';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; Phone; Text[20])
        {
            Caption = 'Phone';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser" where(Blocked = const(false));

            trigger OnValidate()
            var
                SalespersonPurchaser: Record "Salesperson/Purchaser";
                ShpfyStaffMember: Record "Shpfy Staff Member";
                SalespersonPurchaserMappingErr: Label '%1 = %2 already mapped for the Shopify Staff Member %3.', Comment = '%1 = Salesperson/Purchaser table caption, %2 = Salesperson/Purchaser code, %3 = Shopify Staff Member name';
            begin
                if "Salesperson Code" <> '' then begin
                    ShpfyStaffMember.SetRange("Shop Code", "Shop Code");
                    ShpfyStaffMember.SetFilter(Id, '<>%1', Id);
                    ShpfyStaffMember.SetRange("Salesperson Code", "Salesperson Code");
                    if ShpfyStaffMember.FindFirst() then
                        Error(SalespersonPurchaserMappingErr, SalespersonPurchaser.TableCaption(), "Salesperson Code", ShpfyStaffMember.Name);
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