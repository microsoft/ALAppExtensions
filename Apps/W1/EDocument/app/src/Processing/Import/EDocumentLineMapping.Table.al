#pragma warning disable AS0049, AS0009, AS0005, AS0125
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Processing.Import;

using Microsoft.Purchases.Document;
using Microsoft.Finance.Deferral;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Utilities;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.eServices.EDocument;
using Microsoft.Finance.AllocationAccount;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Foundation.UOM;
using Microsoft.Finance.Dimension;
using System.Reflection;
using Microsoft.Purchases.History;

table 6105 "E-Document Line Mapping"
{
#pragma warning disable AS0034
    Access = Internal;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
#pragma warning restore AS0034
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            Caption = 'E-Document Entry No.';
            ToolTip = 'Specifies the entry number of the e-document.';
            TableRelation = "E-Document"."Entry No";
            DataClassification = SystemMetadata;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            ToolTip = 'Specifies the line number.';
            DataClassification = SystemMetadata;
        }
        field(3; "Purchase Line Type"; Enum "Purchase Line Type")
        {
            Caption = 'Type';
            ToolTip = 'Specifies the type of entity that will be posted for this purchase line, such as Item, Resource, or G/L Account.';
        }
        field(4; "Purchase Type No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies what you''re selling. The options vary, depending on what you choose in the Type field.';
            TableRelation = if ("Purchase Line Type" = const(" ")) "Standard Text"
            else
            if ("Purchase Line Type" = const("G/L Account")) "G/L Account"
            else
            if ("Purchase Line Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Purchase Line Type" = const("Charge (Item)")) "Item Charge"
            else
            if ("Purchase Line Type" = const(Item)) Item
            else
            if ("Purchase Line Type" = const("Allocation Account")) "Allocation Account"
            else
            if ("Purchase Line Type" = const(Resource)) Resource;
        }
        field(5; "Unit of Measure"; Code[20])
        {
            Caption = 'Unit of Measure';
            ToolTip = 'Specifies the unit of measure code.';
            TableRelation = "Unit of Measure";
        }
        field(6; "Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            ToolTip = 'Specifies the deferral code.';
            TableRelation = "Deferral Template";
        }
        field(8; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));


        }
        field(9; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));
        }
        field(50; "E-Doc. Purch. Line History Id"; Integer)
        {
            Caption = 'E-Doc. Purch. Line History Id';
            ToolTip = 'Specifies the ID of the e-document purchase line history.';
            TableRelation = "E-Doc. Purchase Line History"."Entry No.";
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "E-Document Entry No.", "Line No.")
        {
            Clustered = true;
        }
    }

    procedure InsertForEDocumentLine(EDocument: Record "E-Document"; LineNo: Integer)
    begin
        Clear(Rec);
        if Rec.Get(EDocument."Entry No", LineNo) then begin
            Rec."Line No." := LineNo;
            Rec.Validate("E-Document Entry No.", EDocument."Entry No");
            Rec.Modify();
        end;
        Rec."Line No." := LineNo;
        Rec.Validate("E-Document Entry No.", EDocument."Entry No");
        Rec.Insert();
    end;

    /// <summary>
    /// Returns any additional columns defined for this line in a human-readable format.
    /// </summary>
    /// <returns></returns>
    internal procedure AdditionalColumnsDisplayText() AdditionalColumns: Text
    var
        EDocPurchLineFieldSetup: Record "EDoc. Purch. Line Field Setup";
        EDocPurchLineField: Record "E-Document Line - Field";
        Field: Record Field;
        AdditionalColumnValue: Text;
    begin
        if not EDocPurchLineFieldSetup.FindSet() then
            exit;
        repeat
            if Field.Get(Database::"Purch. Inv. Line", EDocPurchLineFieldSetup."Field No.") then;
            if AdditionalColumns <> '' then
                AdditionalColumns += ', ';
            AdditionalColumns += Field.FieldName;
            AdditionalColumns += ': ';
            EDocPurchLineField.Get(Rec, EDocPurchLineFieldSetup);
            AdditionalColumnValue := EDocPurchLineField.GetValueAsText();
            if AdditionalColumnValue = '' then
                AdditionalColumnValue := '-';
            AdditionalColumns += AdditionalColumnValue;
        until EDocPurchLineFieldSetup.Next() = 0;
    end;

}
#pragma warning restore AS0049, AS0009, AS0005, AS0125