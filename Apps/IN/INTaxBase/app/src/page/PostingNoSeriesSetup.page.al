// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using System.Automation;
using System.Reflection;
using System.Utilities;

page 18559 "Posting No. Series Setup"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Posting No. Series";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Document Type';
                    ToolTip = 'Specifies the type of document that the entry belongs to.';
                }
                field("Select Condition"; SelectCondition)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Condition';
                    Editable = false;
                    ToolTip = 'Specifies the conditions required for this series to be used.';

                    trigger OnAssistEdit()
                    var
                        RequestPage: Codeunit "Posting No. Series Mgmt.";
                    begin
                        SelectCondition := '';
                        RequestPage.OpendynamicRequestPage(Rec);
                        SelectCondition := GetConditionAsDisplayText();
                    end;
                }
                field("Posting No. Series"; Rec."Posting No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting no. series for different documents type.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SelectCondition := '';
        if Rec."Table Id" <> 0 then
            SelectCondition := GetConditionAsDisplayText();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SelectCondition := '';
    end;

    var
        SelectCondition: Text;
        ObjectIDNotFoundErr: Label 'Error : Table ID %1 not found', Comment = '%1=Table Id';

    local procedure GetConditionAsDisplayText(): Text
    var
        Allobj: Record AllObj;
        RecordRef: RecordRef;
        IStream: InStream;
        COnditionText: Text;
        ExitMsg: Label 'Always';
    begin
        if not Allobj.Get(Allobj."Object Type"::Table, Rec."Table Id") then
            exit(StrSubstNo(ObjectIDNotFoundErr, Rec."Table Id"));
        RecordRef.Open(Rec."Table ID");
        Rec.CalcFields(Condition);
        if not Rec.Condition.HasValue() then
            exit(ExitMsg);

        Rec.Condition.CreateInStream(IStream);
        IStream.Read(COnditionText);
        RecordRef.SetView(COnditionText);
        if RecordRef.GetFilters() <> '' then
            exit(RecordRef.GetFilters());
        RecordRef.Close();
    end;

    local procedure ConvertEventConditionsToFilters(var RecRef: RecordRef): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
    begin
        if Rec.Condition.HasValue() then begin
            Rec.CalcFields(Condition);
            TempBlob.FromRecord(Rec, Rec.FieldNo(Condition));
            RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob);
        end;
    end;
}
