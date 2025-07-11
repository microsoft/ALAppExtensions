// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Localization;

using Microsoft.Purchases.Document;
using Microsoft.DemoData.Finance;
using Microsoft.eServices.EDocument.Format;
using Microsoft.DemoData.Jobs;
using Microsoft.Inventory.Item;
using Microsoft.DemoData.Foundation;

codeunit 11502 "Create EDocs From Resources US"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    EventSubscriberInstance = Manual;

    var
        EDocFromResourceHelper: Codeunit "E-Doc. From Resource Helper";

    trigger OnRun()
    begin
        BindSubscription(this);
        EDocFromResourceHelper.CreateEDocumentsFromResources();
        UnbindSubscription(this);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. From Resource Helper", OnGetListOfPDFResources, '', false, false)]
    local procedure OnGetListOfPDFResources(var PDFResourcesList: List of [Text]; var IsHandled: Boolean)
    begin
        PDFResourcesList := NavApp.ListResources('PDFs/*.pdf');
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc ADI Handler Mock", OnBeforeGetADIJsonInStream, '', false, false)]
    local procedure OnBeforeGetADIJsonInStream(var InStr: InStream; FileName: Text; var IsHandled: Boolean)
    begin
        NavApp.GetResource('ADIJsons/' + FileName, InStr);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. From Resource Helper", OnBeforeCreateEDocFromResourceMappings, '', false, false)]
    local procedure OnBeforeCreateEDocFromResourceMappings(var IsHandled: Boolean)
    var
        EDocFromResourceMapping: Record "E-Doc From Resource Mapping";
        CreateEDocumentMasterData: Codeunit "Create E-Document Master Data";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
        CreateJobItem: Codeunit "Create Job Item";
    begin
        CreateEDocFromResourceMappingForItem(EDocFromResourceMapping, CreateEDocumentMasterData.PrecisionGrindHome());
        CreateEDocFromResourceMappingForItem(EDocFromResourceMapping, CreateEDocumentMasterData.SmartGrindHome());
        CreateEDocFromResourceMappingForItem(EDocFromResourceMapping, CreateEDocumentMasterData.WholeDecafBeansColombia());
        CreateEDocFromResourceMappingForItem(EDocFromResourceMapping, CreateJobItem.ItemConsumable());
        CreateEDocFromResourceMappingForItem(EDocFromResourceMapping, CreateJobItem.ItemSupply());
        CreateEDocFromResourceMapping(EDocFromResourceMapping, 'IT Services Support period: January', Enum::"Purchase Line Type"::"G/L Account", CreateUSGLAccounts.LicenseFeesRoyalties());
        CreateEDocFromResourceMapping(EDocFromResourceMapping, 'IT Services Support period: February', Enum::"Purchase Line Type"::"G/L Account", CreateUSGLAccounts.LicenseFeesRoyalties());
        CreateEDocFromResourceMapping(EDocFromResourceMapping, 'IT Services Support period: March', Enum::"Purchase Line Type"::"G/L Account", CreateUSGLAccounts.LicenseFeesRoyalties());
        CreateEDocFromResourceMapping(EDocFromResourceMapping, 'IT Services Support period: April', Enum::"Purchase Line Type"::"G/L Account", CreateUSGLAccounts.LicenseFeesRoyalties());
        CreateEDocFromResourceMapping(EDocFromResourceMapping, 'IT Services Support period: May', Enum::"Purchase Line Type"::"G/L Account", CreateUSGLAccounts.LicenseFeesRoyalties());
        CreateEDocFromResourceMapping(EDocFromResourceMapping, 'Shipment, DHL', Enum::"Purchase Line Type"::"G/L Account", CreateUSGLAccounts.FreightFeesForGoods());
        IsHandled := true;
    end;

    local procedure CreateEDocFromResourceMappingForItem(var EDocFromResourceMapping: Record "E-Doc From Resource Mapping"; ItemNo: Code[20])
    var
        Item: Record Item;
        CreateUnitOfMeasure: Codeunit "Create Unit of Measure";
    begin
        Item.Get(ItemNo);
        CreateEDocFromResourceMapping(EDocFromResourceMapping, Item.Description, Enum::"Purchase Line Type"::Item, Item."No.", Item."No.", CreateUnitOfMeasure.Piece());
    end;

    local procedure CreateEDocFromResourceMapping(var EDocFromResourceMapping: Record "E-Doc From Resource Mapping"; Description: Text[100]; Type: Enum "Purchase Line Type"; No: Code[20])
    begin
        CreateEDocFromResourceMapping(EDocFromResourceMapping, Description, Type, No, '', '');
    end;

    local procedure CreateEDocFromResourceMapping(var EDocFromResourceMapping: Record "E-Doc From Resource Mapping"; Description: Text[100]; Type: Enum "Purchase Line Type"; No: Code[20]; ProductCode: Text[100]; UnitOfMeasureCode: Code[10])
    begin
        EDocFromResourceMapping.ID += 1;
        EDocFromResourceMapping.Description := Description;
        EDocFromResourceMapping.Type := Type;
        EDocFromResourceMapping."No." := No;
        EDocFromResourceMapping."Product Code" := ProductCode;
        EDocFromResourceMapping."Unit of Measure" := UnitOfMeasureCode;
        EDocFromResourceMapping.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. From Resource Helper", OnBeforePostPurchaseInvoice, '', false, false)]
    local procedure OnBeforePostPurchaseInvoice(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        CreateTaxGroupUS: Codeunit "Create Tax Group US";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindSet(true);
        repeat
            if PurchaseLine."Tax Group Code" = '' then begin
                PurchaseLine.Validate("Tax Group Code", CreateTaxGroupUS.NonTaxable());
                PurchaseLine.Modify(true);
            end;
        until PurchaseLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. From Resource Helper", OnGetResourceInStreamWhenImportDocument, '', false, false)]
    local procedure OnGetResourceInStreamWhenImportDocument(var InStr: InStream; ResourceName: Text; var IsHandled: Boolean)
    begin
        NavApp.GetResource(ResourceName, InStr);
        IsHandled := true;
    end;
}