codeunit 1913 "MigrationQB Vendor Migrator"
{
    TableNo = "MigrationQB Vendor";

    var
        DocumentNo: Text[30];
        PostingGroupCodeTxt: Label 'QB', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from QB', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendor', '', true, true)]
    procedure OnMigrateVendor(VAR Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        MigrationQBVendor: Record "MigrationQB Vendor";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"MigrationQB Vendor" then
            exit;
        MigrationQBVendor.Get(RecordIdToMigrate);
        MigrateVendorDetails(MigrationQBVendor, Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendorPostingGroups', '', true, true)]
    procedure OnMigrateVendorPostingGroups(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"MigrationQB Vendor" then
            exit;

        Sender.CreatePostingSetupIfNeeded(
            CopyStr(PostingGroupCodeTxt, 1, 5),
            CopyStr(PostingGroupDescriptionTxt, 1, 20),
            HelperFunctions.GetPostingAccountNumber('PayablesAccount')
        );
        Sender.SetVendorPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        Sender.ModifyVendor(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendorTransactions', '', true, true)]
    procedure OnMigrateVendorTransactions(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        MigrationQBVendor: Record "MigrationQB Vendor";
        MigrationQBVendTrans: Record "MigrationQB VendorTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"MigrationQB Vendor" then
            exit;

        MigrationQBVendor.Get(RecordIdToMigrate);
        Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 5), '', '');

        MigrationQBVendTrans.SetRange(VendorRef, MigrationQBVendor.ListId);
        MigrationQBVendTrans.SetRange(TransType, MigrationQBVendTrans.TransType::Invoice);
        if MigrationQBVendTrans.FindSet() then
            repeat
                Sender.CreateGeneralJournalLine(
                    CopyStr(PostingGroupCodeTxt, 1, 5),
                    CopyStr(MigrationQBVendTrans.GLDocNo, 1, 20),
                    GetVendorName(MigrationQBVendor),
                    MigrationQBVendTrans.TxnDate,
                    0D,
                    -MigrationQBVendTrans.Amount,
                    -MigrationQBVendTrans.Amount,
                    '',
                    HelperFunctions.GetPostingAccountNumber('PayablesAccount')
                );
                Sender.SetGeneralJournalLineDocumentType(MigrationQBVendTrans.TransType::Invoice);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(MigrationQBVendTrans.DocNumber);
            until MigrationQBVendTrans.Next() = 0;

        /* 		MigrationQBVendTrans.Reset();
                MigrationQBVendTrans.SetRange(VendorRef,MigrationQBVendor.ListId);
                MigrationQBVendTrans.SetRange(TransType,MigrationQBVendTrans.TransType::Payment);
                if MigrationQBVendTrans.FindSet() then
                    repeat
                        Sender.CreateGeneralJournalLine(
                            CopyStr(PostingGroupCodeTxt,1,5),
                            MigrationQBVendTrans.GLDocNo,
                            GetVendorName(MigrationQBVendor),
                            MigrationQBVendTrans.TxnDate,
                            0D,
                            MigrationQBVendTrans.Amount,
                            MigrationQBVendTrans.Amount,
                            '',
                            HelperFunctions.GetPostingAccountNumber('PayablesAccount')
                        );
                        Sender.SetGeneralJournalLineDocumentType(MigrationQBVendTrans.TransType::Payment);
                        Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt,1,10));
                        Sender.SetGeneralJournalLineExternalDocumentNo(MigrationQBVendTrans.DocNumber);				
                    until MigrationQBVendTrans.Next() = 0; */

        /* MigrationQBVendTrans.Reset();
		MigrationQBVendTrans.SetRange(VendorRef,MigrationQBVendor.ListId);
		MigrationQBVendTrans.SetRange(TransType,MigrationQBVendTrans.TransType::"Credit Memo");
		MigrationQBVendTrans.SetFilter(OpenAmount, '> %1', 0.0);
		if MigrationQBVendTrans.FindSet() then
			repeat
				Sender.CreateGeneralJournalLine(
					CopyStr(PostingGroupCodeTxt,1,5),
					MigrationQBVendTrans.GLDocNo,
					GetVendorName(MigrationQBVendor),
					MigrationQBVendTrans.TxnDate,
					0D,
					MigrationQBVendTrans.Amount,
					MigrationQBVendTrans.Amount,
					'',
					HelperFunctions.GetPostingAccountNumber('PayablesAccount')
				);
				Sender.SetGeneralJournalLineDocumentType(MigrationQBVendTrans.TransType::"Credit Memo");
				Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt,1,10));
				Sender.SetGeneralJournalLineExternalDocumentNo(MigrationQBVendTrans.DocNumber);				
			until MigrationQBVendTrans.Next() = 0;	 */
    end;

    local procedure MigrateVendorDetails(MigrationQBVendor: Record "MigrationQB Vendor"; VendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade")
    var
        CompanyInformation: Record "Company Information";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        VendorName: Text[50];
        ContactName: Text[50];
        Country: Code[10];
    begin
        VendorName := GetVendorName(MigrationQBVendor);
        ContactName := GetContactName(MigrationQBVendor);
        if not VendorDataMigrationFacade.CreateVendorIfNeeded(CopyStr(MigrationQBVendor.Id, 1, 20), VendorName) then
            exit;

        if (CopyStr(MigrationQBVendor.BillAddrCountry, 1, 10) <> '') then begin
            HelperFunctions.CreateCountyIfNeeded(CopyStr(MigrationQBVendor.BillAddrCountry, 1, 10), CopyStr(MigrationQBVendor.BillAddrCountry, 1, 10));
            Country := CopyStr(MigrationQBVendor.BillAddrCountry, 1, 10);
        end else begin
            CompanyInformation.Get();
            Country := CompanyInformation."Country/Region Code";
        end;

        if (CopyStr(MigrationQBVendor.BillAddrPostalCode, 1, 20) <> '') and (CopyStr(MigrationQBVendor.BillAddrCity, 1, 30) <> '') then
            VendorDataMigrationFacade.CreatePostCodeIfNeeded(CopyStr(MigrationQBVendor.BillAddrPostalCode, 1, 20),
                CopyStr(MigrationQBVendor.BillAddrCity, 1, 30), CopyStr(MigrationQBVendor.BillAddrState, 1, 20), Country);

        VendorDataMigrationFacade.SetAddress(CopyStr(MigrationQBVendor.BillAddrLine1, 1, 50),
            CopyStr(MigrationQBVendor.BillAddrLine2, 1, 50), CopyStr(MigrationQBVendor.BillAddrCountry, 1, 10),
            CopyStr(MigrationQBVendor.BillAddrPostalCode, 1, 20), CopyStr(MigrationQBVendor.BillAddrCity, 1, 30));
        VendorDataMigrationFacade.SetContact(ContactName);
        VendorDataMigrationFacade.SetPhoneNo(MigrationQBVendor.PrimaryPhone);
        VendorDataMigrationFacade.SetVendorPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        VendorDataMigrationFacade.SetGenBusPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        VendorDataMigrationFacade.SetFaxNo(MigrationQBVendor.Fax);
        VendorDataMigrationFacade.SetEmail(CopyStr(SelectStr(1, CopyStr(MigrationQBVendor.PrimaryEmailAddr, 1, 80)), 1, 80));
        VendorDataMigrationFacade.SetHomePage(CopyStr(MigrationQBVendor.WebAddr, 1, 80));
        VendorDataMigrationFacade.SetVendorPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        VendorDataMigrationFacade.ModifyVendor(true);
    end;

    local procedure GetVendorName(MigrationQBVendor: Record "MigrationQB Vendor"): Text[50]
    var
        name: Text[50];
    begin
        if (MigrationQBVendor.CompanyName = '') And (MigrationQBVendor.GivenName = '') And (MigrationQBVendor.FamilyName = '') then begin
            name := CopyStr(MigrationQBVendor.DisplayName, 1, 50);
            exit(name);
        end;

        if MigrationQBVendor.CompanyName = '' then
            name := CopyStr(MigrationQBVendor.GivenName + ' ' + MigrationQBVendor.FamilyName, 1, 50)
        else
            name := CopyStr(MigrationQBVendor.CompanyName, 1, 50);

        exit(name);
    end;

    local procedure GetContactName(MigrationQBVendor: Record "MigrationQB Vendor"): Text[50]
    var
        name: Text[50];
    begin
        name := CopyStr(MigrationQBVendor.GivenName + ' ' + MigrationQBVendor.FamilyName, 1, 50);
        exit(name);
    end;

    procedure GetAll(IsOnline: Boolean)
    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        JArray: JsonArray;
        Success: Boolean;
    begin
        DeleteAll();

        if IsOnline then
            Success := HelperFunctions.GetEntities('Select * from Vendor', 'Vendor', JArray)
        else
            Success := HelperFunctions.GetEntities('Vendor', JArray);

        if Success then begin
            GetVendorsFromJson(JArray);
            GetTransactions(IsOnline);
        end;
    end;

    procedure PopulateStagingTable(JArray: JsonArray)
    begin
        GetVendorsFromJson(JArray);
    end;

    procedure DeleteAll()
    var
        MigrationQBVendor: Record "MigrationQB Vendor";
        MigrationQBVendorTrans: Record "MigrationQB VendorTrans";
    begin
        MigrationQBVendor.DeleteAll();
        MigrationQBVendorTrans.DeleteAll();
        Commit();
    end;

    local procedure GetVendorsFromJson(JArray: JsonArray)
    var
        MigrationQBVendor: Record "MigrationQB Vendor";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[15];
        i: Integer;
    begin
        i := 0;

        WHILE JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'Id')), 1, 15);

            if not MigrationQBVendor.Get(EntityId) then begin
                MigrationQBVendor.Init();
                MigrationQBVendor.VALIDATE(MigrationQBVendor.Id, EntityId);
                MigrationQBVendor.Insert(true);
            end;

            RecordVariant := MigrationQBVendor;
            UpdateVendorFromJson(RecordVariant, ChildJToken);
            MigrationQBVendor := RecordVariant;
            MigrationQBVendor.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure UpdateVendorFromJson(var RecordVariant: Variant; JToken: JsonToken)
    var
        MigrationQBVendor: Record "MigrationQB Vendor";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendor.FieldNO(GivenName), JToken.AsObject(), 'GivenName');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendor.FieldNO(FamilyName), JToken.AsObject(), 'FamilyName');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendor.FieldNO(CompanyName), JToken.AsObject(), 'CompanyName');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendor.FieldNO(DisplayName), JToken.AsObject(), 'DisplayName');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendor.FieldNO(BillAddrLine1), JToken.AsObject(), 'BillAddr.Line1');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendor.FieldNO(BillAddrLine2), JToken.AsObject(), 'BillAddr.Line2');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendor.FieldNO(BillAddrCity), JToken.AsObject(), 'BillAddr.City');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendor.FieldNO(BillAddrCountry), JToken.AsObject(), 'BillAddr.Country');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendor.FieldNO(BillAddrPostalCode), JToken.AsObject(), 'BillAddr.PostalCode');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendor.FieldNO(BillAddrCountrySubDivCode), JToken.AsObject(), 'BillAddr.CountrySubDivisionCode');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendor.FieldNO(PrimaryPhone), JToken.AsObject(), 'PrimaryPhone.FreeFormNumber');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendor.FieldNO(PrimaryEmailAddr), JToken.AsObject(), 'PrimaryEmailAddr.Address');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendor.FieldNO(WebAddr), JToken.AsObject(), 'WebAddr.URI');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendor.FieldNO(Fax), JToken.AsObject(), 'Fax.FreeFormNumber');

        if HelperFunctions.IsOnlineData() then begin
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendor.FieldNO(ListId), JToken.AsObject(), 'Id');
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendor.FieldNO(BillAddrState), JToken.AsObject(), 'BillAddr.CountrySubDivisionCode');
        end else begin
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendor.FieldNO(ListId), JToken.AsObject(), 'ListId');
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendor.FieldNO(BillAddrState), JToken.AsObject(), 'BillAddr.State');
        end;
    end;

    local procedure GetTransactions(IsOnline: Boolean)
    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        JArray: JsonArray;
    begin
        DocumentNo := 'V00000';
        if IsOnline then begin
            if (HelperFunctions.GetEntities('Select * from Bill where Balance != ''0'' ', 'Bill', JArray)) then
                GetInvoicesFromJson(JArray);
            /* if (HelperFunctions.GetEntities('BillPayment',JToken)) then
				GetPaymentsFromJson(JToken); */
            /* if (HelperFunctions.GetEntities('VendorCreditMemo',JToken)) then
				GetVendorCreditMemosFromJson(JToken); */
        end else
            if (HelperFunctions.GetEntities('Bill', JArray)) then
                GetInvoicesFromJson(JArray);
        /* if (HelperFunctions.GetEntities('BillPayment',JToken)) then
            GetPaymentsFromJson(JToken); */
        /* if (HelperFunctions.GetEntities('VendorCreditMemo',JToken)) then
            GetVendorCreditMemosFromJson(JToken); */
    end;

    local procedure GetInvoicesFromJson(JArray: JsonArray);
    var
        MigrationQBVendTrans: Record "MigrationQB VendorTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[15];
        i: Integer;
    begin
        i := 0;

        WHILE JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'Id')), 1, 15);

            if not MigrationQBVendTrans.Get(EntityId) then begin
                MigrationQBVendTrans.Init();
                MigrationQBVendTrans.Validate(MigrationQBVendTrans.Id, EntityId);
                MigrationQBVendTrans.Validate(MigrationQBVendTrans.TransType, MigrationQBVendTrans.TransType::Invoice);
                MigrationQBVendTrans.Insert(true);
            end;

            RecordVariant := MigrationQBVendTrans;
            DocumentNo := CopyStr(IncStr(DocumentNo), 1, 30);
            UpdateInvoiceFromJson(RecordVariant, ChildJToken, DocumentNo);
            MigrationQBVendTrans := RecordVariant;
            MigrationQBVendTrans.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure GetPaymentsFromJson(JArray: JsonArray);
    var
        MigrationQBVendTrans: Record "MigrationQB VendorTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        AppliedChildJToken: JsonToken;
        AppliedJArray: JsonArray;
        EntityId: Text[15];
        id: Text[100];
        i: Integer;
        j: Integer;
    begin
        i := 0;

        WHILE JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'Id')), 1, 15);

            if HelperFunctions.GetArrayPropertyValueFromJObjectByName(ChildJToken.AsObject(), 'AppliedToTxnRetList', AppliedJArray) then begin
                j := 0;
                WHILE AppliedJArray.Get(j, AppliedChildJToken) do begin
                    MigrationQBVendTrans.Init();
                    id := CopyStr(HelperFunctions.GetTextFromJToken(AppliedChildJToken, 'TxnId'), 1, 100);
                    if not MigrationQBVendTrans.Get(id, MigrationQBVendTrans.TransType::Payment) then begin
                        MigrationQBVendTrans.Validate(MigrationQBVendTrans.Id, id);
                        MigrationQBVendTrans.Validate(MigrationQBVendTrans.TransType, MigrationQBVendTrans.TransType::Payment);
                        MigrationQBVendTrans.Insert(true);
                        RecordVariant := MigrationQBVendTrans;
                        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(Amount), AppliedChildJToken.AsObject(), 'UnappliedAmt');
                        DocumentNo := CopyStr(IncStr(DocumentNo), 1, 30);
                        UpdatePaymentFromJson(RecordVariant, ChildJToken, DocumentNo);
                        MigrationQBVendTrans := RecordVariant;
                        MigrationQBVendTrans.Modify(true);
                    end;
                    j := j + 1;
                end;
            end;
            i := i + 1;
        end;
    end;

    local procedure GetVendorCreditMemosFromJson(JArray: JsonArray);
    var
        MigrationQBVendTrans: Record "MigrationQB VendorTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[15];
        i: Integer;
    begin
        i := 0;

        WHILE JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'Id')), 1, 15);

            if not MigrationQBVendTrans.Get(EntityId, MigrationQBVendTrans.TransType::"Credit Memo") then begin
                MigrationQBVendTrans.Init();
                MigrationQBVendTrans.Validate(MigrationQBVendTrans.Id, EntityId);
                MigrationQBVendTrans.Validate(MigrationQBVendTrans.TransType, MigrationQBVendTrans.TransType::"Credit Memo");
                MigrationQBVendTrans.Insert(true);
            end;

            RecordVariant := MigrationQBVendTrans;
            DocumentNo := CopyStr(IncStr(DocumentNo), 1, 30);
            UpdateVendorCreditMemoFromJson(RecordVariant, ChildJToken, DocumentNo);
            MigrationQBVendTrans := RecordVariant;
            MigrationQBVendTrans.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure UpdateInvoiceFromJson(var RecordVariant: Variant; JToken: JsonToken; DocumentNo: Text[30])
    var
        MigrationQBVendTrans: Record "MigrationQB VendorTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(DocNumber), JToken.AsObject(), 'DocNumber');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(TxnDate), JToken.AsObject(), 'TxnDate');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(DueDate), JToken.AsObject(), 'DueDate');
        HelperFunctions.UpdateFieldWithValue(RecordVariant, MigrationQBVendTrans.FieldNo(GLDocNo), DocumentNo);

        if HelperFunctions.IsOnlineData() then begin
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(Amount), JToken.AsObject(), 'Balance');
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendTrans.FieldNo(VendorRef), JToken.AsObject(), 'VendorRef.value');
        end else begin
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(Amount), JToken.AsObject(), 'RemainingBalance');
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendTrans.FieldNo(VendorRef), JToken.AsObject(), 'VendorRef.ListId');
        end;
    end;

    local procedure UpdatePaymentFromJson(var RecordVariant: Variant; JToken: JsonToken; DocumentNo: Text[30])
    var
        MigrationQBVendTrans: Record "MigrationQB VendorTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(DocNumber), JToken.AsObject(), 'TxnNumber');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendTrans.FieldNo(VendorRef), JToken.AsObject(), 'PayeeEntityRef.ListId');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(TxnDate), JToken.AsObject(), 'TxnDate');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(DueDate), JToken.AsObject(), 'DueDate');
        HelperFunctions.UpdateFieldWithValue(RecordVariant, MigrationQBVendTrans.FieldNo(GLDocNo), DocumentNo);
    end;

    local procedure UpdateVendorCreditMemoFromJson(var RecordVariant: Variant; JToken: JsonToken; DocumentNo: Text[30])
    var
        MigrationQBVendTrans: Record "MigrationQB VendorTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(DocNumber), JToken.AsObject(), 'TxnNumber');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBVendTrans.FieldNo(VendorRef), JToken.AsObject(), 'VendorRef.ListId');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(TxnDate), JToken.AsObject(), 'TxnDate');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(DueDate), JToken.AsObject(), 'DueDate');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(Amount), JToken.AsObject(), 'CreditAmount');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBVendTrans.FieldNo(OpenAmount), JToken.AsObject(), 'OpenAmount');
        HelperFunctions.UpdateFieldWithValue(RecordVariant, MigrationQBVendTrans.FieldNo(GLDocNo), DocumentNo);
    end;
}