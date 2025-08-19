// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Localization;

using Microsoft.eServices.EDocument.Format;
using Microsoft.DemoData.Finance;
using Microsoft.Purchases.Document;

codeunit 17211 "Create EDocs From Resources NZ"
{
    Access = Internal;
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
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        CreateEDocFromResourceMapping(EDocFromResourceMapping, 'IT Support Support period: January', Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.ConsultantServices());
        CreateEDocFromResourceMapping(EDocFromResourceMapping, 'IT Support Support period: February', Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.ConsultantServices());
        CreateEDocFromResourceMapping(EDocFromResourceMapping, 'IT Support Support period: March', Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.ConsultantServices());
        CreateEDocFromResourceMapping(EDocFromResourceMapping, 'IT Support Support period: April', Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.ConsultantServices());
        CreateEDocFromResourceMapping(EDocFromResourceMapping, 'IT Support Support period: April', Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.ConsultantServices());
        CreateEDocFromResourceMapping(EDocFromResourceMapping, 'IT Support Support period: May', Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.ConsultantServices());
        CreateEDocFromResourceMapping(EDocFromResourceMapping, 'IT Support Support period: December', Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.ConsultantServices());
        IsHandled := true;
    end;


    local procedure CreateEDocFromResourceMapping(var EDocFromResourceMapping: Record "E-Doc From Resource Mapping"; Description: Text[100]; Type: Enum "Purchase Line Type"; No: Code[20])
    begin
        EDocFromResourceMapping.ID += 1;
        EDocFromResourceMapping.Description := Description;
        EDocFromResourceMapping.Type := Type;
        EDocFromResourceMapping."No." := No;
        EDocFromResourceMapping.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. From Resource Helper", OnGetResourceInStreamWhenImportDocument, '', false, false)]
    local procedure OnGetResourceInStreamWhenImportDocument(var InStr: InStream; ResourceName: Text; var IsHandled: Boolean)
    begin
        NavApp.GetResource(ResourceName, InStr);
        IsHandled := true;
    end;
}