// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.TCS.TCSBase;
using System.Utilities;

tableextension 18840 "Sales Line" extends "Sales Line"
{
    fields
    {
        field(18838; "TCS Nature of Collection"; Code[10])
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TCSNatureOfCollection: Record "TCS Nature Of Collection";
                TCSNatureOfCollection2Err: Label 'You are not allowed to select this Nature of Collection in Document No.=%1, Line No.=%2.', Comment = '%1 = Document No., %2 = Line No.';
            begin
                if "TCS Nature of Collection" = '' then
                    exit;

                TCSNatureOfCollection.Get("TCS Nature of Collection");
                if TCSNatureOfCollection."TCS on Recpt. Of Pmt." then
                    Error(TCSNatureOfCollection2Err, "Document No.", "Line No.");
            end;
        }
        field(18839; "Assessee Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    procedure AllowedNOCLookup(var SalesLine: Record "sales line"; CustomerNo: Code[20])
    var
        AllowedNOC: Record "Allowed NOC";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        TCSNatureOfCollections: Page "TCS Nature Of Collections";
    begin
        TCSNatureOfCollection.Reset();
        AllowedNOC.Reset();
        AllowedNOC.SetRange("Customer No.", CustomerNo);
        if AllowedNOC.FindSet() then
            repeat
                TCSNatureOfCollection.SetRange(Code, AllowedNOC."TCS Nature of Collection");
                TCSNatureOfCollection.SetRange("TCS on Recpt. Of Pmt.", false);
                if TCSNatureOfCollection.FindFirst() then
                    TCSNatureOfCollection.Mark(true);
            until AllowedNOC.Next() = 0;
        TCSNatureOfCollection.SetRange(Code);
        TCSNatureOfCollection.MarkedOnly(true);
        TCSNatureOfCollections.SetTableView(TCSNatureOfCollection);
        TCSNatureOfCollections.LookupMode(true);
        TCSNatureOfCollections.Editable(false);
        if TCSNatureOfCollections.RunModal() = Action::LookupOK then begin
            TCSNatureOfCollections.GetRecord(TCSNatureOfCollection);
            CheckDefaultandAssignNOC(SalesLine, TCSNatureOfCollection.Code);
        end;
    end;

    local procedure CheckDefaultandAssignNOC(var SalesLine: Record "sales line"; NocType: Code[10])
    var
        AllowedNOC: Record "Allowed Noc";
    begin
        AllowedNOC.Reset();
        AllowedNOC.SetRange("Customer No.", SalesLine."Sell-to Customer No.");
        AllowedNOC.SetRange("TCS Nature of Collection", NocType);
        if AllowedNOC.FindFirst() then
            SalesLine.Validate("TCS Nature of Collection", AllowedNOC."TCS Nature of Collection")
        else
            ConfirmAssignNOC(SalesLine, NocType);
    end;

    local procedure ConfirmAssignNOC(var SalesLine: Record "sales line"; NOCType: Code[10])
    var
        AllowedNOC: Record "Allowed NOC";
        ConfirmManagement: Codeunit "Confirm Management";
        NOCConfirmMsg: Label 'NOC Type %1 is not attached with Customer No. %2, Do you want to assign to customer & Continue ?', Comment = '%1=Noc Type., %2=Customer No.';
    begin
        if ConfirmManagement.GetResponseOrDefault
        (StrSubstNo(NOCConfirmMsg, NOCType, SalesLine."Sell-to Customer No."), true)
        then begin
            AllowedNOC.Init();
            AllowedNOC."TCS Nature of Collection" := NOCType;
            AllowedNOC."Customer No." := SalesLine."Sell-to Customer No.";
            AllowedNOC.Insert();
            SalesLine.Validate("TCS Nature of Collection", NOCType);
        end;
    end;
}
