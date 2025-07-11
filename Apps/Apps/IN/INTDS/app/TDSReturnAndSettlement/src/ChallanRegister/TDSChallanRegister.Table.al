// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

using System.Security.User;
using Microsoft.Finance.TDS.TDSBase;
using System.Security.AccessControl;

table 18749 "TDS Challan Register"
{
    Caption = 'TDS Challan Register';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Challan No."; Code[20])
        {
            Caption = 'Challan No.';
            DataClassification = CustomerContent;
        }
        field(3; "Challan Date"; Date)
        {
            Caption = 'Challan Date';
            DataClassification = CustomerContent;
        }
        field(4; "BSR Code"; Code[20])
        {
            Caption = 'BSR Code';
            DataClassification = CustomerContent;
        }
        field(5; "Bank Name"; Text[100])
        {
            Caption = 'Bank Name';
            DataClassification = CustomerContent;
        }
        field(6; "TDS Interest Amount"; Decimal)
        {
            Caption = 'TDS Interest Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "TDS Others"; Decimal)
        {
            Caption = 'TDS Others';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Paid By Book Entry"; Boolean)
        {
            Caption = 'Paid By Book Entry';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Pay TDS Document No."; Code[20])
        {
            Caption = 'Pay TDS Document No.';
            DataClassification = CustomerContent;
        }
        field(10; "Total TDS Amount"; Decimal)
        {
            Caption = 'Total TDS Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Total Surcharge Amount"; Decimal)
        {
            Caption = 'Total Surcharge Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Total eCess Amount"; Decimal)
        {
            Caption = 'Total eCess Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Total Invoice Amount"; Decimal)
        {
            Caption = 'Total Invoice Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Total TDS Including SHE Cess"; Decimal)
        {
            Caption = 'Total TDS Including SHE Cess';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; "TDS Payment Date"; Date)
        {
            Caption = 'TDS Payment Date';
            DataClassification = CustomerContent;
        }
        field(16; "Non Resident Payment"; Boolean)
        {
            Caption = 'Non Resident Payment';
            DataClassification = CustomerContent;
        }
        field(17; "T.A.N. No."; Code[20])
        {
            Caption = 'T.A.N. No.';
            DataClassification = CustomerContent;
        }
        field(18; "TDS Section"; Code[10])
        {
            Caption = 'TDS Section';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19; "Check / DD No."; Code[10])
        {
            Caption = 'Check / DD No.';
            DataClassification = CustomerContent;
        }
        field(20; "Check / DD Date"; Date)
        {
            Caption = 'Check / DD Date';
            DataClassification = CustomerContent;
        }
        field(21; "Last Bank Challan No."; Code[20])
        {
            Caption = 'Last Bank Challan No.';
            DataClassification = CustomerContent;
        }
        field(22; "Last Bank-Branch Code"; Code[20])
        {
            Caption = 'Last Bank-Branch Code';
            DataClassification = CustomerContent;
        }
        field(23; "Last Date of Challan No."; Date)
        {
            Caption = 'Last Date of Challan No.';
            DataClassification = CustomerContent;
        }
        field(24; "Last TDS Others"; Decimal)
        {
            Caption = 'Last TDS Others';
            DataClassification = CustomerContent;
        }
        field(25; "Last TDS Interest"; Decimal)
        {
            Caption = 'Last TDS Interest';
            DataClassification = CustomerContent;
        }
        field(26; "Financial Year"; Code[9])
        {
            Caption = 'Financial Year';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27; "Assessment Year"; Code[9])
        {
            Caption = 'Assessment Year';
            DataClassification = CustomerContent;
        }
        field(28; Quarter; Code[10])
        {
            Caption = 'Quarter';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(29; "Nil Challan Indicator"; Boolean)
        {
            Caption = 'Nil Challan Indicator';
            DataClassification = CustomerContent;
        }
        field(30; "Last Transfer Voucher No."; Code[20])
        {
            Caption = 'Last Transfer Voucher No.';
            DataClassification = CustomerContent;
        }
        field(31; "Transfer Voucher No."; Code[9])
        {
            Caption = 'Transfer Voucher No.';
            DataClassification = CustomerContent;
        }
        field(32; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = User."User Name";

            trigger OnLookup()
            begin
                LookupUserID("User ID");
            end;
        }
        field(33; "Total SHE Cess Amount"; Decimal)
        {
            Caption = 'Total SHE Cess Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(34; "Minor Head Code"; Enum "Minor Head Type")
        {
            Caption = 'Minor Head Code';
            DataClassification = CustomerContent;
        }
        field(35; "TDS Fee"; Decimal)
        {
            Caption = 'TDS Fee';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; Quarter, "Financial Year")
        {
        }
    }

    procedure LookupUserID(var UserName: Code[50])
    var
        SID: Guid;
    begin
        LookupUser(UserName, SID);
    end;

    local procedure LookupUser(var UserName: Code[50]; var SID: Guid): Boolean
    var
        User: Record User;
    begin
        User.SetCurrentKey("User Name");
        User."User Name" := UserName;
        if User.Find('=><') then;
        if Page.RunModal(Page::Users, User) = Action::LookupOK then begin
            UserName := User."User Name";
            SID := User."User Security ID";
            exit(true)
        end;
        exit(false);
    end;
}
