// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using System.IO;

page 5025 "Service Declaration Overview"
{
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Service Declaration Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Service Transaction Code"; Rec."Service Transaction Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the service transaction code.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the source entry.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code of the source entry.';
                }
                field("Sales Amount (LCY)"; Rec."Sales Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Sales Amount (LCY) of the source value entry.';
                }
                field("Purchase Amount (LCY)"; Rec."Purchase Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Purchase Amount (LCY) of the source value entry.';
                }
            }
        }
    }

    actions
    {
    }

    procedure SetSource(ServiceDeclarationHeader: Record "Service Declaration Header")
    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
        ServiceDeclarationLine: Record "Service Declaration Line";
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
        TempDataExchFlowFieldGrBuff: Record "Data Exch. FlowField Gr. Buff." temporary;
        ExportMapping: Codeunit "Export Mapping";
        RecRef: RecordRef;
        IsHandled: Boolean;
    begin
        ServiceDeclarationLine.SetRange("Service Declaration No.", ServiceDeclarationHeader."No.");
        if ServiceDeclarationLine.IsEmpty() then
            exit;

        OnBeforeGetDataExchDefinition(ServiceDeclarationHeader, DataExchDef, IsHandled);
        if not IsHandled then begin
            ServiceDeclarationSetup.Get();
            ServiceDeclarationSetup.TestField("Data Exch. Def. Code");
            DataExchDef.Get(ServiceDeclarationSetup."Data Exch. Def. Code");
        end;

        DataExchMapping.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchMapping.SetRange("Table ID", Database::"Service Declaration Line");
        DataExchMapping.FindFirst();

        ExportMapping.GetSourceRecRefBuffer(RecRef, TempDataExchFlowFieldGrBuff, DataExchMapping, ServiceDeclarationLine.GetView());
        if not RecRef.FindSet() then
            exit;

        repeat
            RecRef.SetTable(Rec);
            Rec.Insert();
        until RecRef.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDataExchDefinition(var ServiceDeclarationHeader: Record "Service Declaration Header"; var DataExchDef: Record "Data Exch. Def"; var IsHandled: Boolean);
    begin
    end;
}
