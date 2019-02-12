// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148167 "Elster Codeunits UT"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURES] [Elster] [UT]
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetProductNameTruncatesLongApplicationVersion()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        VATStatementName: Record "VAT Statement Name";
        ElsterCodeunitsUT: Codeunit "Elster Codeunits UT";
        FileManagement: Codeunit "File Management";
        ApplicationSystemConstants: Codeunit "Application System Constants";
        XmlDoc: XmlDocument;
        XmlNodeProdVersion: XmlNode;
        XmlNsMgr: XmlNamespaceManager;
        InStr: InStream;
        FilePath: Text;
    begin
        // [SCENARIO 222243] "ProduktVersion" does not exceed 50 characters in created XML file by report "Create XML-File VAT Adv.Notif."
        Initialize();

        BindSubscription(ElsterCodeunitsUT);

        FilePath := FileManagement.ServerTempFileName('XML');

        SetupCompanyInformation();
        CreateSalesVATAdvanceNotificationForTransmit(SalesVATAdvanceNotif);

        VATStatementName.ModifyAll("Sales VAT Adv. Notif.", true);

        Report.Run(Report::"Create XML-File VAT Adv.Notif.", false, false, SalesVATAdvanceNotif);

        UnbindSubscription(ElsterCodeunitsUT);

        SalesVATAdvanceNotif.CalcFields("XML Submission Document");
        SalesVATAdvanceNotif."XML Submission Document".Export(FilePath);

        SalesVATAdvanceNotif."XML Submission Document".CreateInStream(InStr);

        XmlDocument.ReadFrom(InStr, XmlDoc);
        XmlNsMgr.NameTable(XmlDoc.NameTable());
        XmlNsMgr.AddNamespace('elster', 'http://www.elster.de/elsterxml/schema/v11');
        XmlDoc.SelectSingleNode('//elster:ProduktVersion', XmlNsMgr, XmlNodeProdVersion);
        Assert.AreEqual(PadStr(ApplicationSystemConstants.ApplicationVersion(), 50, 'A'), XmlNodeProdVersion.AsXmlElement().InnerText(), 'Wrong ProduktVersion.');
    end;

    local procedure Initialize()
    begin
        LibrarySetupStorage.Restore();

        if IsInitialized then
            exit;

        IsInitialized := true;

        LibrarySetupStorage.Save(Database::"Company Information");
    end;

    local procedure CreateSalesVATAdvanceNotif(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.");
    begin
        SalesVATAdvanceNotif."No." := LibraryUTUtility.GetNewCode();
        SalesVATAdvanceNotif."XML-File Creation Date" := WorkDate();
        SalesVATAdvanceNotif."Contact for Tax Office" := LibraryUTUtility.GetNewCode();
        SalesVATAdvanceNotif.Insert();
    end;

    local procedure SetupCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        CompanyInformation."Tax Office Area" := CompanyInformation."Tax Office Area"::Berlin;
        CompanyInformation."Tax Office Number" := Format(LibraryRandom.RandIntInRange(1000, 9999));
        CompanyInformation."Registration No." := LibraryUtility.GenerateGUID();
        CompanyInformation."VAT Representative" := LibraryUtility.GenerateGUID();
        CompanyInformation.Modify();
    end;

    local procedure CreateSalesVATAdvanceNotificationForTransmit(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.");
    begin
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif);
        SalesVATAdvanceNotif.SetRecFilter();
        SalesVATAdvanceNotif."Starting Date" := CalcDate('<-CY>', WorkDate());
        SalesVATAdvanceNotif."XML-File Creation Date" := 0D;
        SalesVATAdvanceNotif.Modify();
    end;

    [MessageHandler]
    procedure MessageHandler(MessageText: Text[1024]);
    begin
    end;

    [EventSubscriber(ObjectType::Report, Report::"Create XML-File VAT Adv.Notif.", 'OnGetProductVersion', '', true, true)]
    local procedure ExtendProductVersionOnGetProducVersion(var ProductVersion: Text);
    begin
        ProductVersion := PADSTR(ProductVersion, 50, 'A') + 'Z';
    end;
}