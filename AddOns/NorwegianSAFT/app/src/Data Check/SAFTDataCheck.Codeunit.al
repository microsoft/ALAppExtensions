codeunit 10679 "SAF-T Data Check"
{
    TableNo = "SAF-T Export Header";

    var
        ErrorMessageMgt: Codeunit "Error Message Management";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        MissedValueErr: Label 'A field value missed';
        MultipleValuesMissedErr: Label 'At least one of the following values must not be blank: %1', Comment = '%1 = list of field captions';
        OrTok: Label ' or ';

    trigger OnRun()
    var
        TypeHelper: Codeunit "Type Helper";
        ErrorContextElement: Codeunit "Error Context Element";
    begin
        ErrorMessageMgt.Activate(ErrorMessageHandler);
        ErrorMessageMgt.PushContext(ErrorContextElement, RecordId(), 0, '');
        CheckCompanyInformation();
        CheckGLSetup();
        CheckGLAccounts();
        CheckCustomers();
        CheckVendors();
        CheckVATPostingSetup();
        CheckDimensions();
        OnCollectErrors(ErrorMessageMgt);
        If ErrorMessageHandler.HasErrors() then begin
            "Data check status" := "Data check status"::Failed;
            ErrorMessageHandler.ShowErrors()
        end else
            "Data check status" := "Data check status"::Passed;
        "Latest Data Check Date/Time" := TypeHelper.GetCurrentDateTimeInUserTimeZone();
        Modify();
    end;

    procedure ThrowNotificationIfCustomerDataMissed(Rec: Record Customer): Boolean
    var
        TempSAFTMissingField: Record "SAF-T Missing Field" temporary;
    begin
        GetMissedValueFieldsForCustomer(TempSAFTMissingField, Rec);
        exit(IsAllowClosePage(TempSAFTMissingField));
    end;

    procedure ThrowNotificationIfVendorDataMissed(Rec: Record Vendor): Boolean
    var
        TempSAFTMissingField: Record "SAF-T Missing Field" temporary;
    begin
        GetMissedValueFieldsForVendor(TempSAFTMissingField, Rec);
        exit(IsAllowClosePage(TempSAFTMissingField));
    end;

    procedure ThrowNotificationIfCompanyInformationDataMissed(Rec: Record "Company Information"): Boolean
    var
        TempSAFTMissingField: Record "SAF-T Missing Field" temporary;
    begin
        GetMissedValueFieldsForCompanyInformation(TempSAFTMissingField, Rec);
        exit(IsAllowClosePage(TempSAFTMissingField));
    end;

    procedure ThrowNotificationIfBankAccountDataMissed(Rec: Record "Bank Account"): Boolean
    var
        TempSAFTMissingField: Record "SAF-T Missing Field" temporary;
    begin
        GetMissedValueFiedsForBankAccount(TempSAFTMissingField, Rec);
        exit(IsAllowClosePage(TempSAFTMissingField));
    end;

    procedure ThrowNotificationIfCustomerBankAccountDataMissed(Rec: Record "Customer Bank Account"): Boolean
    var
        TempSAFTMissingField: Record "SAF-T Missing Field" temporary;
    begin
        GetMissedValueFiedsForCustomerBankAccount(TempSAFTMissingField, Rec);
        exit(IsAllowClosePage(TempSAFTMissingField));
    end;

    procedure ThrowNotificationIfVendorBankAccountDataMissed(Rec: Record "Vendor Bank Account"): Boolean
    var
        TempSAFTMissingField: Record "SAF-T Missing Field" temporary;
    begin
        GetMissedValueFiedsForVendorBankAccount(TempSAFTMissingField, Rec);
        exit(IsAllowClosePage(TempSAFTMissingField));
    end;

    local procedure CheckCompanyInformation()
    var
        TempSAFTMissingField: Record "SAF-T Missing Field" temporary;
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        GetMissedValueFieldsForCompanyInformation(TempSAFTMissingField, CompanyInformation);
        LogErrorsGivenSAFTMissingFieldSource(TempSAFTMissingField);

        CheckBankAccounts();
    end;

    local procedure CheckBankAccounts()
    var
        BankAccount: Record "Bank Account";
        TempSAFTMissingField: Record "SAF-T Missing Field" temporary;
    begin
        If not BankAccount.FindSet() then
            exit;
        repeat
            GetMissedValueFiedsForBankAccount(TempSAFTMissingField, BankAccount);
            LogErrorsGivenSAFTMissingFieldSource(TempSAFTMissingField);
        until BankAccount.Next() = 0;
    end;

    local procedure CheckGLSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."LCY Code" = '' then
            LogMissedValueError(GeneralLedgerSetup.RecordId(), GeneralLedgerSetup.FieldNo("LCY Code"));
    end;

    local procedure CheckGLAccounts()
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.FindSet();
        repeat
            if GLAccount.Name = '' then
                LogMissedValueError(GLAccount.RecordId(), GLAccount.FieldNo(Name));
        until GLAccount.Next() = 0;
    end;

    local procedure CheckCustomers()
    var
        Customer: Record Customer;
        TempSAFTMissingField: Record "SAF-T Missing Field" temporary;
    begin
        if not Customer.FindSet() then
            exit;

        repeat
            GetMissedValueFieldsForCustomer(TempSAFTMissingField, Customer);
            LogErrorsGivenSAFTMissingFieldSource(TempSAFTMissingField);
        until Customer.Next() = 0;
        CheckCustomerBankAccounts();
    end;

    local procedure CheckCustomerBankAccounts()
    var
        CustomerBankAccount: Record "Customer Bank Account";
        TempSAFTMissingField: Record "SAF-T Missing Field" temporary;
    begin
        if not CustomerBankAccount.FindSet() then
            exit;

        repeat
            GetMissedValueFiedsForCustomerBankAccount(TempSAFTMissingField, CustomerBankAccount);
            LogErrorsGivenSAFTMissingFieldSource(TempSAFTMissingField);
        until CustomerBankAccount.Next() = 0;
    end;

    local procedure CheckVendors()
    var
        Vendor: Record Vendor;
        TempSAFTMissingField: Record "SAF-T Missing Field" temporary;
    begin
        if not Vendor.FindSet() then
            exit;

        repeat
            GetMissedValueFieldsForVendor(TempSAFTMissingField, Vendor);
            LogErrorsGivenSAFTMissingFieldSource(TempSAFTMissingField);
        until Vendor.Next() = 0;
        CheckVendorBankAccounts();
    end;

    local procedure CheckVendorBankAccounts()
    var
        VendorBankAccount: Record "Vendor Bank Account";
        TempSAFTMissingField: Record "SAF-T Missing Field" temporary;
    begin
        if not VendorBankAccount.FindSet() then
            exit;

        repeat
            GetMissedValueFiedsForVendorBankAccount(TempSAFTMissingField, VendorBankAccount);
            LogErrorsGivenSAFTMissingFieldSource(TempSAFTMissingField);
        until VendorBankAccount.Next() = 0;
    end;

    local procedure CheckVATPostingSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not VATPostingSetup.FindSet() then
            exit;

        repeat
            if VATPostingSetup."Sales SAF-T Tax Code" = 0 then
                LogMissedValueError(VATPostingSetup.RecordId(), VATPostingSetup.FieldNo("Sales SAF-T Tax Code"));
            if VATPostingSetup."Purchase SAF-T Tax Code" = 0 then
                LogMissedValueError(VATPostingSetup.RecordId(), VATPostingSetup.FieldNo("Purchase SAF-T Tax Code"));
        until VATPostingSetup.Next() = 0;
    end;

    local procedure CheckDimensions()
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
    begin
        if not Dimension.FindSet() then
            exit;

        repeat
            if Dimension."SAF-T Analysis Type" = '' then
                LogMissedValueError(Dimension.RecordId(), Dimension.FieldNo("SAF-T Analysis Type"));
            if Dimension.Name = '' then
                LogMissedValueError(Dimension.RecordId(), Dimension.FieldNo(Name));
        until Dimension.Next() = 0;

        if not DimensionValue.FindSet() then
            exit;

        repeat
            if DimensionValue.Name = '' then
                LogMissedValueError(DimensionValue.RecordId(), DimensionValue.FieldNo(Name));
        until DimensionValue.Next() = 0;
    end;

    local procedure GetMissedValueFieldsForCompanyInformation(var TempSAFTMissingField: Record "SAF-T Missing Field" temporary; CompanyInformation: Record "Company Information")
    var
        Employee: Record Employee;
        FieldList: List of [Integer];
    begin
        TempSAFTMissingField.Reset();
        TempSAFTMissingField.DeleteAll();
        CompanyInformation.Get();
        if CompanyInformation."VAT Registration No." = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, CompanyInformation, CompanyInformation.FieldNo("VAT Registration No."));
        if CompanyInformation."Country/Region Code" = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, CompanyInformation, CompanyInformation.FieldNo("Country/Region Code"));
        if CompanyInformation.Name = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, CompanyInformation, CompanyInformation.FieldNo(Name));
        if CompanyInformation.Address = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, CompanyInformation, CompanyInformation.FieldNo(Address));
        if CompanyInformation.City = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, CompanyInformation, CompanyInformation.FieldNo(City));
        if CompanyInformation."Post Code" = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, CompanyInformation, CompanyInformation.FieldNo("Post Code"));
        if CompanyInformation."SAF-T Contact No." = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, CompanyInformation, CompanyInformation.FieldNo("SAF-T Contact No."))
        else begin
            Employee.Get(CompanyInformation."SAF-T Contact No.");
            if Employee."First Name" = '' then
                AddBasicSAFTMissingField(TempSAFTMissingField, Employee, Employee.FieldNo("First Name"));
        end;
        if (CompanyInformation.IBAN = '') and (CompanyInformation."Bank Account No." = '') and
           (CompanyInformation."Bank Name" = '') and (CompanyInformation."Bank Branch No." = '')
        then begin
            FieldList.Add(CompanyInformation.FieldNo(IBAN));
            FieldList.Add(CompanyInformation.FieldNo("Bank Account No."));
            FieldList.Add(CompanyInformation.FieldNo("Bank Name"));
            FieldList.Add(CompanyInformation.FieldNo("Bank Branch No."));
            AddSAFTMissingFieldGroup(TempSAFTMissingField, CompanyInformation, FieldList);
        end;
    end;

    local procedure GetMissedValueFiedsForBankAccount(var TempSAFTMissingField: Record "SAF-T Missing Field" temporary; BankAccount: Record "Bank Account")
    var
        FieldList: List of [Integer];
    begin
        TempSAFTMissingField.Reset();
        TempSAFTMissingField.DeleteAll();
        if (BankAccount.IBAN = '') and (BankAccount."Bank Account No." = '') and
            (BankAccount.Name + BankAccount."Name 2" = '') and (BankAccount."Bank Branch No." = '')
        then begin
            FieldList.Add(BankAccount.FieldNo(IBAN));
            FieldList.Add(BankAccount.FieldNo("Bank Account No."));
            FieldList.Add(BankAccount.FieldNo(Name));
            FieldList.Add(BankAccount.FieldNo("Bank Branch No."));
            AddSAFTMissingFieldGroup(TempSAFTMissingField, BankAccount, FieldList);
        end;
    end;

    local procedure GetMissedValueFiedsForCustomerBankAccount(var TempSAFTMissingField: Record "SAF-T Missing Field" temporary; CustomerBankAccount: Record "Customer Bank Account")
    var
        FieldList: List of [Integer];
    begin
        TempSAFTMissingField.Reset();
        TempSAFTMissingField.DeleteAll();
        if (CustomerBankAccount.IBAN = '') and (CustomerBankAccount."Bank Account No." = '') and
            (CustomerBankAccount.Name + CustomerBankAccount."Name 2" = '') and (CustomerBankAccount."Bank Branch No." = '')
        then begin
            FieldList.Add(CustomerBankAccount.FieldNo(IBAN));
            FieldList.Add(CustomerBankAccount.FieldNo("Bank Account No."));
            FieldList.Add(CustomerBankAccount.FieldNo(Name));
            FieldList.Add(CustomerBankAccount.FieldNo("Bank Branch No."));
            AddSAFTMissingFieldGroup(TempSAFTMissingField, CustomerBankAccount, FieldList);
        end;
    end;

    local procedure GetMissedValueFiedsForVendorBankAccount(var TempSAFTMissingField: Record "SAF-T Missing Field" temporary; VendorBankAccount: Record "Vendor Bank Account")
    var
        FieldList: List of [Integer];
    begin
        TempSAFTMissingField.Reset();
        TempSAFTMissingField.DeleteAll();
        if (VendorBankAccount.IBAN = '') and (VendorBankAccount."Bank Account No." = '') and
            (VendorBankAccount.Name + VendorBankAccount."Name 2" = '') and (VendorBankAccount."Bank Branch No." = '')
        then begin
            FieldList.Add(VendorBankAccount.FieldNo(IBAN));
            FieldList.Add(VendorBankAccount.FieldNo("Bank Account No."));
            FieldList.Add(VendorBankAccount.FieldNo(Name));
            FieldList.Add(VendorBankAccount.FieldNo("Bank Branch No."));
            AddSAFTMissingFieldGroup(TempSAFTMissingField, VendorBankAccount, FieldList);
        end;
    end;

    local procedure GetMissedValueFieldsForCustomer(var TempSAFTMissingField: Record "SAF-T Missing Field" temporary; Customer: Record Customer)
    begin
        TempSAFTMissingField.Reset();
        TempSAFTMissingField.DeleteAll();
        if Customer.Name = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, Customer, Customer.FieldNo(Name));
        if Customer.Address = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, Customer, Customer.FieldNo(Address));
        if Customer.City = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, Customer, Customer.FieldNo(City));
        if Customer."Post Code" = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, Customer, Customer.FieldNo("Post Code"));
        if Customer.Contact = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, Customer, Customer.FieldNo(Contact));
    end;

    local procedure GetMissedValueFieldsForVendor(var TempSAFTMissingField: Record "SAF-T Missing Field" temporary; Vendor: Record Vendor)
    begin
        TempSAFTMissingField.Reset();
        TempSAFTMissingField.DeleteAll();
        if Vendor.Name = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, Vendor, Vendor.FieldNo(Name));
        if Vendor.Address = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, Vendor, Vendor.FieldNo(Address));
        if Vendor.City = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, Vendor, Vendor.FieldNo(City));
        if Vendor."Post Code" = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, Vendor, Vendor.FieldNo("Post Code"));
        if Vendor.Contact = '' then
            AddBasicSAFTMissingField(TempSAFTMissingField, Vendor, Vendor.FieldNo(Contact));
    end;

    local procedure LogErrorsGivenSAFTMissingFieldSource(var TempSAFTMissingField: Record "SAF-T Missing Field" temporary)
    var
        FieldList: Text;
    begin
        TempSAFTMissingField.Reset();
        TempSAFTMissingField.SetRange("Group No.", 0);
        if TempSAFTMissingField.FindSet() then
            repeat
                LogMissedValueError(TempSAFTMissingField."Record ID", TempSAFTMissingField."Field No.");
            until TempSAFTMissingField.Next() = 0;
        TempSAFTMissingField.SetFilter("Group No.", '<>%1', 0);
        if TempSAFTMissingField.FindSet() then
            repeat
                TempSAFTMissingField.SetRange("Group No.", TempSAFTMissingField."Group No.");
                FieldList := '';
                repeat
                    FieldList += TempSAFTMissingField."Field Caption";
                until TempSAFTMissingField.Next() = 0;
                LogContextError(StrSubstNo(MultipleValuesMissedErr, FieldList), TempSAFTMissingField."Record ID");
                TempSAFTMissingField.SetFilter("Group No.", '<>%1', 0);
            until TempSAFTMissingField.Next() = 0;
    end;

    local procedure AddBasicSAFTMissingField(var TempSAFTMissingField: Record "SAF-T Missing Field" temporary; RecordVar: Variant; FieldNo: Integer)
    begin
        AddSAFTMissingField(TempSAFTMissingField, RecordVar, FieldNo, 0);
    end;

    local procedure AddSAFTMissingFieldGroup(var TempSAFTMissingField: Record "SAF-T Missing Field" temporary; RecordVar: Variant; FieldNos: List of [Integer])
    var
        RecRef: RecordRef;
        GroupNo: Integer;
        i: Integer;
        FieldNo: Integer;
    begin
        RecRef.GetTable(RecordVar);
        TempSAFTMissingField.Reset();
        TempSAFTMissingField.SetCurrentKey("Table No.", "Group No.");
        TempSAFTMissingField.SetRange("Table No.", RecRef.Number());
        TempSAFTMissingField.SetFilter("Group No.", '<>%1', 0);
        If TempSAFTMissingField.FindLast() then
            GroupNo := TempSAFTMissingField."Group No.";
        GroupNo += 1;
        for i := 1 to FieldNos.Count() do begin
            FieldNos.Get(i, FieldNo);
            AddSAFTMissingField(TempSAFTMissingField, RecordVar, FieldNo, GroupNo);
        end;
    end;

    local procedure AddSAFTMissingField(var TempSAFTMissingField: Record "SAF-T Missing Field" temporary; RecordVar: Variant; FieldNo: Integer; GroupNo: Integer)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        RecRef.GetTable(RecordVar);
        TempSAFTMissingField."Table No." := RecRef.Number();
        TempSAFTMissingField."Field No." := FieldNo;
        if TempSAFTMissingField.Find() then
            exit;
        TempSAFTMissingField."Record ID" := RecRef.RecordId();
        FldRef := RecRef.Field(FieldNo);
        TempSAFTMissingField."Field Caption" := copystr(FldRef.Caption(), 1, MaxStrLen(TempSAFTMissingField."Field Caption"));
        TempSAFTMissingField."Group No." := GroupNo;
        TempSAFTMissingField.Insert();
    end;

    Local procedure LogMissedValueError(SourceVariant: Variant; SourceFieldNo: Integer)
    begin
        LogError(MissedValueErr, SourceVariant, SourceFieldNo);
    end;

    local procedure LogContextError(ErrorMessage: Text; SourceVariant: Variant)
    begin
        LogError(ErrorMessage, SourceVariant, 0);
    end;

    local procedure LogError(ErrorMessage: Text; SourceVariant: Variant; SourceFieldNo: Integer)
    begin
        ErrorMessageMgt.LogContextFieldError(0, ErrorMessage, SourceVariant, SourceFieldNo, '');
    end;

    local procedure AddText(var ResultedText: Text; TextToAdd: Text)
    begin
        If TextToAdd = '' then
            exit;
        if ResultedText <> '' then
            ResultedText += ',';
        ResultedText += TextToAdd;
    end;

    local procedure IsAllowClosePage(var TempSAFTMissingField: Record "SAF-T Missing Field" temporary): Boolean
    var
        SAFTDataCheck: Page "SAF-T Data Check";
        MissedValuesList: Text;
        FieldList: Text;
    begin
        TempSAFTMissingField.Reset();
        TempSAFTMissingField.SetRange("Group No.", 0);
        If TempSAFTMissingField.FindSet() then
            repeat
                AddText(MissedValuesList, TempSAFTMissingField."Field Caption");
            until TempSAFTMissingField.Next() = 0;
        TempSAFTMissingField.SetFilter("Group No.", '<>%1', 0);
        if TempSAFTMissingField.FindSet() then
            repeat
                FieldList := '';
                TempSAFTMissingField.SetRange("Group No.", TempSAFTMissingField."Group No.");
                repeat
                    if FieldList <> '' then
                        FieldList += OrTok;
                    FieldList += TempSAFTMissingField."Field Caption";
                until TempSAFTMissingField.Next() = 0;
                AddText(MissedValuesList, FieldList);
                TempSAFTMissingField.SetFilter("Group No.", '<>%1', 0);
            until TempSAFTMissingField.Next() = 0;
        If MissedValuesList = '' then
            exit(true);
        SAFTDataCheck.SetMissedValuesList(MissedValuesList);
        SAFTDataCheck.LookupMode(true);
        exit(ACTION::No = SAFTDataCheck.RunModal());
    end;


    [IntegrationEvent(false, false)]
    local procedure OnCollectErrors(var ErrorMessageMgt: Codeunit "Error Message Management")
    begin

    end;
}