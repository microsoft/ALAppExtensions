#if not CLEAN18
#pragma warning disable AL0432, AL0603
codeunit 31117 "Sync.Dep.Fld-StatRepSetup CZL"
{
    Permissions = tabledata "Stat. Reporting Setup" = rimd,
                  tabledata "Statutory Reporting Setup CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Stat. Reporting Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertStatReportingSetup(var Rec: Record "Stat. Reporting Setup")
    begin
        SyncStatReportingSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Stat. Reporting Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyStatReportingSetup(var Rec: Record "Stat. Reporting Setup")
    begin
        SyncStatReportingSetup(Rec);
    end;

    local procedure SyncStatReportingSetup(var Rec: Record "Stat. Reporting Setup")
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Stat. Reporting Setup") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statutory Reporting Setup CZL");
        StatutoryReportingSetupCZL.ChangeCompany(Rec.CurrentCompany);
        if not StatutoryReportingSetupCZL.Get(Rec."Primary Key") then begin
            StatutoryReportingSetupCZL.Init();
            StatutoryReportingSetupCZL."Primary Key" := Rec."Primary Key";
            StatutoryReportingSetupCZL.SystemId := Rec.SystemId;
            StatutoryReportingSetupCZL.Insert(false, true);
        end;
#if not CLEAN17
        StatutoryReportingSetupCZL."Company Trade Name" := Rec."Company Trade Name";
        StatutoryReportingSetupCZL."Company Trade Name Appendix" := Rec."Company Trade Name Appendix";
        StatutoryReportingSetupCZL."Municipality No." := Rec."Municipality No.";
        StatutoryReportingSetupCZL.Street := Rec.Street;
        StatutoryReportingSetupCZL."House No." := Rec."House No.";
        StatutoryReportingSetupCZL."Apartment No." := Rec."Apartment No.";
        StatutoryReportingSetupCZL."VAT Control Report Nos." := Rec."VAT Control Report Nos.";
        StatutoryReportingSetupCZL."Simplified Tax Document Limit" := Rec."Simplified Tax Document Limit";
        StatutoryReportingSetupCZL."Data Box ID" := Rec."Data Box ID";
        StatutoryReportingSetupCZL."VAT Control Report E-mail" := Rec."VAT Control Report E-mail";
        StatutoryReportingSetupCZL."VAT Control Report XML Format" := Rec."VAT Control Report Xml Format";
        StatutoryReportingSetupCZL."Tax Office Number" := Rec."Tax Office Number";
        StatutoryReportingSetupCZL."Tax Office Region Number" := Rec."Tax Office Region Number";
        case Rec."Taxpayer Type" of
            Rec."Taxpayer Type"::Corporation:
                StatutoryReportingSetupCZL."Company Type" := StatutoryReportingSetupCZL."Company Type"::Corporate;
            Rec."Taxpayer Type"::Individual:
                StatutoryReportingSetupCZL."Company Type" := StatutoryReportingSetupCZL."Company Type"::Individual;
        end;
        StatutoryReportingSetupCZL."Individual First Name" := Rec."Natural Person First Name";
        StatutoryReportingSetupCZL."Individual Surname" := Rec."Natural Person Surname";
        StatutoryReportingSetupCZL."Individual Title" := Rec."Natural Person Title";
        StatutoryReportingSetupCZL."Individual Employee No." := Rec."Natural Employee No.";
        StatutoryReportingSetupCZL."Official Code" := Rec."Official Code";
        StatutoryReportingSetupCZL."Official Name" := Rec."Official Name";
        StatutoryReportingSetupCZL."Official First Name" := Rec."Official First Name";
        StatutoryReportingSetupCZL."Official Surname" := Rec."Official Surname";
        StatutoryReportingSetupCZL."Official Birth Date" := Rec."Official Birth Date";
        StatutoryReportingSetupCZL."Official Reg.No.of Tax Adviser" := Rec."Official Reg.No.of Tax Adviser";
        StatutoryReportingSetupCZL."Official Registration No." := Rec."Official Registration No.";
        StatutoryReportingSetupCZL."Official Type" := Rec."Official Type";
        StatutoryReportingSetupCZL."VAT Statement Country Name" := Rec."VAT Statement Country Name";
        StatutoryReportingSetupCZL."VAT Stat. Auth. Employee No." := Rec."VAT Stat. Auth.Employee No.";
        StatutoryReportingSetupCZL."VAT Stat. Filled Employee No." := Rec."VAT Stat. Filled by Empl. No.";
        StatutoryReportingSetupCZL."Tax Payer Status" := Rec."Tax Payer Status";
        StatutoryReportingSetupCZL."Primary Business Activity Code" := Rec."Main Economic Activity I Code";
        StatutoryReportingSetupCZL."VIES Declaration Nos." := Rec."VIES Declaration Nos.";
        StatutoryReportingSetupCZL."VIES Decl. Auth. Employee No." := Rec."VIES Decl. Auth. Employee No.";
        StatutoryReportingSetupCZL."VIES Decl. Filled Employee No." := Rec."VIES Decl. Filled by Empl. No.";
        StatutoryReportingSetupCZL."VIES Number of Lines" := Rec."VIES Number of Lines";
#endif
        StatutoryReportingSetupCZL."Transaction Type Mandatory" := Rec."Transaction Type Mandatory";
        StatutoryReportingSetupCZL."Transaction Spec. Mandatory" := Rec."Transaction Spec. Mandatory";
        StatutoryReportingSetupCZL."Transport Method Mandatory" := Rec."Transport Method Mandatory";
        StatutoryReportingSetupCZL."Shipment Method Mandatory" := Rec."Shipment Method Mandatory";
        StatutoryReportingSetupCZL."Tariff No. Mandatory" := Rec."Tariff No. Mandatory";
        StatutoryReportingSetupCZL."Net Weight Mandatory" := Rec."Net Weight Mandatory";
        StatutoryReportingSetupCZL."Country/Region of Origin Mand." := Rec."Country/Region of Origin Mand.";
        StatutoryReportingSetupCZL."Get Tariff No. From" := "Intrastat Detail Source CZL".FromInteger(Rec."Get Tariff No. From");
        StatutoryReportingSetupCZL."Get Net Weight From" := "Intrastat Detail Source CZL".FromInteger(Rec."Get Net Weight From");
        StatutoryReportingSetupCZL."Get Country/Region of Origin" := "Intrastat Detail Source CZL".FromInteger(Rec."Get Country/Region of Origin");
        StatutoryReportingSetupCZL."Intrastat Rounding Type" := Rec."Intrastat Rounding Type";
        StatutoryReportingSetupCZL."No Item Charges in Intrastat" := Rec."No Item Charges in Intrastat";
        StatutoryReportingSetupCZL."Intrastat Declaration Nos." := Rec."Intrastat Declaration Nos.";
        StatutoryReportingSetupCZL."Stat. Value Reporting" := Rec."Stat. Value Reporting";
        StatutoryReportingSetupCZL."Cost Regulation %" := Rec."Cost Regulation %";
        StatutoryReportingSetupCZL."Include other Period add.Costs" := Rec."Include other Period add.Costs";
        StatutoryReportingSetupCZL.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statutory Reporting Setup CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statutory Reporting Setup CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertStatutoryReportingSetupCZL(var Rec: Record "Statutory Reporting Setup CZL")
    begin
        SyncStatutoryReportingSetupCZL(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statutory Reporting Setup CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyStatutoryReportingSetupCZL(var Rec: Record "Statutory Reporting Setup CZL")
    begin
        SyncStatutoryReportingSetupCZL(Rec);
    end;

    local procedure SyncStatutoryReportingSetupCZL(var Rec: Record "Statutory Reporting Setup CZL")
    var
        StatReportingSetup: Record "Stat. Reporting Setup";
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Statutory Reporting Setup CZL") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Stat. Reporting Setup");
        StatReportingSetup.ChangeCompany(Rec.CurrentCompany);
        if not StatReportingSetup.Get(Rec."Primary Key") then begin
            StatReportingSetup.Init();
            StatReportingSetup."Primary Key" := Rec."Primary Key";
            StatReportingSetup.SystemId := Rec.SystemId;
            StatReportingSetup.Insert(false, true);
        end;
#if not CLEAN17
        StatReportingSetup."Company Trade Name" := Rec."Company Trade Name";
        StatReportingSetup."Company Trade Name Appendix" := Rec."Company Trade Name Appendix";
        StatReportingSetup."Municipality No." := Rec."Municipality No.";
        StatReportingSetup.Street := Rec.Street;
        StatReportingSetup."House No." := Rec."House No.";
        StatReportingSetup."Apartment No." := Rec."Apartment No.";
        StatReportingSetup."VAT Control Report Nos." := Rec."VAT Control Report Nos.";
        StatReportingSetup."Simplified Tax Document Limit" := Rec."Simplified Tax Document Limit";
        StatReportingSetup."Data Box ID" := Rec."Data Box ID";
        StatReportingSetup."VAT Control Report E-mail" := Rec."VAT Control Report E-mail";
        StatReportingSetup."VAT Control Report XML Format" := Rec."VAT Control Report Xml Format";
        StatReportingSetup."Tax Office Number" := Rec."Tax Office Number";
        StatReportingSetup."Tax Office Region Number" := Rec."Tax Office Region Number";
        case Rec."Company Type" of
            Rec."Company Type"::" ",
            Rec."Company Type"::Corporate:
                StatReportingSetup."Taxpayer Type" := StatReportingSetup."Taxpayer Type"::Corporation;
            Rec."Company Type"::Individual:
                StatReportingSetup."Taxpayer Type" := StatReportingSetup."Taxpayer Type"::Individual;
        end;
        StatReportingSetup."Natural Person First Name" := Rec."Individual First Name";
        StatReportingSetup."Natural Person Surname" := Rec."Individual Surname";
        StatReportingSetup."Natural Person Title" := Rec."Individual Title";
        StatReportingSetup."Natural Employee No." := Rec."Individual Employee No.";
        StatReportingSetup."Official Code" := Rec."Official Code";
        StatReportingSetup."Official Name" := Rec."Official Name";
        StatReportingSetup."Official First Name" := Rec."Official First Name";
        StatReportingSetup."Official Surname" := Rec."Official Surname";
        StatReportingSetup."Official Birth Date" := Rec."Official Birth Date";
        StatReportingSetup."Official Reg.No.of Tax Adviser" := Rec."Official Reg.No.of Tax Adviser";
        StatReportingSetup."Official Registration No." := Rec."Official Registration No.";
        StatReportingSetup."Official Type" := Rec."Official Type";
        StatReportingSetup."VAT Statement Country Name" := Rec."VAT Statement Country Name";
        StatReportingSetup."VAT Stat. Auth.Employee No." := Rec."VAT Stat. Auth. Employee No.";
        StatReportingSetup."VAT Stat. Filled by Empl. No." := Rec."VAT Stat. Filled Employee No.";
        StatReportingSetup."Tax Payer Status" := Rec."Tax Payer Status";
        StatReportingSetup."Main Economic Activity I Code" := Rec."Primary Business Activity Code";
        StatReportingSetup."VIES Declaration Nos." := Rec."VIES Declaration Nos.";
        StatReportingSetup."VIES Decl. Auth. Employee No." := Rec."VIES Decl. Auth. Employee No.";
        StatReportingSetup."VIES Decl. Filled by Empl. No." := Rec."VIES Decl. Filled Employee No.";
        StatReportingSetup."VIES Number of Lines" := Rec."VIES Number of Lines";
#endif
        StatReportingSetup."Transaction Type Mandatory" := Rec."Transaction Type Mandatory";
        StatReportingSetup."Transaction Spec. Mandatory" := Rec."Transaction Spec. Mandatory";
        StatReportingSetup."Transport Method Mandatory" := Rec."Transport Method Mandatory";
        StatReportingSetup."Shipment Method Mandatory" := Rec."Shipment Method Mandatory";
        StatReportingSetup."Tariff No. Mandatory" := Rec."Tariff No. Mandatory";
        StatReportingSetup."Net Weight Mandatory" := Rec."Net Weight Mandatory";
        StatReportingSetup."Country/Region of Origin Mand." := Rec."Country/Region of Origin Mand.";
        StatReportingSetup."Get Tariff No. From" := Rec."Get Tariff No. From".AsInteger();
        StatReportingSetup."Get Net Weight From" := Rec."Get Net Weight From".AsInteger();
        StatReportingSetup."Get Country/Region of Origin" := Rec."Get Country/Region of Origin".AsInteger();
        StatReportingSetup."Intrastat Rounding Type" := Rec."Intrastat Rounding Type";
        StatReportingSetup."No Item Charges in Intrastat" := Rec."No Item Charges in Intrastat";
        StatReportingSetup."Intrastat Declaration Nos." := Rec."Intrastat Declaration Nos.";
        StatReportingSetup."Stat. Value Reporting" := Rec."Stat. Value Reporting";
        StatReportingSetup."Cost Regulation %" := Rec."Cost Regulation %";
        StatReportingSetup."Include other Period add.Costs" := Rec."Include other Period add.Costs";
        StatReportingSetup.Modify(false);
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Stat. Reporting Setup");

        UnbindSubscription(SyncLoopingHelper);
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Company Information");
        CompanyInformation.ChangeCompany(Rec.CurrentCompany);
        if not CompanyInformation.Get() then begin
            CompanyInformation.Init();
            CompanyInformation.Insert();
        end;
#if not CLEAN17
        CompanyInformation."Primary Business Activity" := Rec."Primary Business Activity";
        CompanyInformation."Court Authority No." := Rec."Court Authority No.";
        CompanyInformation."Tax Authority No." := Rec."Tax Authority No.";
        CompanyInformation."Registration Date" := Rec."Registration Date";
        CompanyInformation."Equity Capital" := Rec."Equity Capital";
        CompanyInformation."Paid Equity Capital" := Rec."Paid Equity Capital";
        CompanyInformation."General Manager No." := Rec."General Manager No.";
        CompanyInformation."Accounting Manager No." := Rec."Accounting Manager No.";
        CompanyInformation."Finance Manager No." := Rec."Finance Manager No.";
        CompanyInformation.Modify(false);
#endif
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Company Information");

        UnbindSubscription(SyncLoopingHelper);
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"General Ledger Setup");
        GeneralLedgerSetup.ChangeCompany(Rec.CurrentCompany);
        if not GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup.Init();
            GeneralLedgerSetup.Insert();
        end;
#if not CLEAN17
        GeneralLedgerSetup."Company Officials Nos." := Rec."Company Official Nos.";
        GeneralLedgerSetup.Modify(false);
#endif
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"General Ledger Setup");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif