// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;
using System.Reflection;
using Microsoft.Purchases.History;
using System.Apps;
using Microsoft.eServices.EDocument;

page 6101 "E-Doc. Purch. Line Fields"
{
    PageType = ListPart;
#pragma warning disable AS0035 // extensible = false, released in 26.2, changed for 26.3, this is breaking if someone uses Page.run(6104, Rec)
    SourceTable = "ED Purchase Line Field Setup";
#pragma warning restore AS0035
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(LineFields)
            {
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    Caption = 'Field No.';
                    ToolTip = 'Specifies the number of the field in the table.';
                    Editable = false;
                }
                field(FieldName; Name)
                {
                    ApplicationArea = All;
                    Caption = 'Field Name';
                    ToolTip = 'Specifies the name of the field in the table.';
                    Editable = false;
                }
                field(AddAdditionalField; AddAdditionalField)
                {
                    ApplicationArea = All;
                    Caption = 'Consider additional field';
                    ToolTip = 'Specifies whether to consider this additional field for new inbound e-documents.';

                    trigger OnValidate()
                    begin
                        Rec.ApplySetup(AddAdditionalField, Rec);
                        CurrPage.Update();
                    end;
                }
                field(OwnerApp; OwnerApp)
                {
                    ApplicationArea = All;
                    Caption = 'Application';
                    Editable = false;
                    ToolTip = 'Specifies the application that owns the field.';
                }
            }
        }
    }

    var
        EDocumentService: Record "E-Document Service";
        Name, OwnerApp : Text;
        AddAdditionalField: Boolean;
        NoEDocumentServiceErr: Label 'No E-Document Service was provided to page.';

    trigger OnOpenPage()
    var
    begin
        if EDocumentService.Code = '' then
            Error(NoEDocumentServiceErr);
        Rec.AllPurchaseLineFields(EDocumentService, Rec);
        Rec.FindFirst();
    end;


    trigger OnAfterGetRecord()
    var
        EDocHistPurchLineFields: Record "ED Purchase Line Field Setup";
        Field: Record Field;
        NAVInstalledApp: Record "NAV App Installed App";
        AppPublishedByPlaceholderLbl: Label '%1 by %2', Comment = '%1 is the name of the app, %2 is the publisher of the app';
    begin
        AddAdditionalField := false;
        if EDocHistPurchLineFields.Get(Rec."Field No.", Rec."E-Document Service") then
            AddAdditionalField := true;
        if Field.Get(Database::"Purch. Inv. Line", Rec."Field No.") then
            Name := Field.FieldName;
        NAVInstalledApp.SetRange("Package ID", Field."App Package ID");
        if NAVInstalledApp.FindFirst() then
            OwnerApp := StrSubstNo(AppPublishedByPlaceholderLbl, NAVInstalledApp.Name, NAVInstalledApp.Publisher);
    end;

#pragma warning disable AA0244
    internal procedure SetEDocumentService(EDocumentService: Record "E-Document Service")
#pragma warning restore AA0244
    begin
        this.EDocumentService := EDocumentService;
    end;

}