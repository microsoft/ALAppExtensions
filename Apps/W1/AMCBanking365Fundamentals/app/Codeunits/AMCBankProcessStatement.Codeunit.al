codeunit 20126 "AMC Bank Process Statement"
{
    Permissions = TableData "Data Exch." = rimd;
    TableNo = "Bank Acc. Reconciliation Line";

    trigger OnRun()
    var
        DataExch: Record "Data Exch.";
        RecordRef: RecordRef;
    begin
        DataExch.Get("Data Exch. Entry No.");
        RecordRef.GetTable(Rec);
        ProgressWindowDialog.Open(ProgressMsg);
        ProcessImportedStatement(DataExch, RecordRef);
        ProgressWindowDialog.Close();
    end;

    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        ProgressMsg: Label 'Preparing line number #1#######', Comment = '#1 = Linenumber';
        ProgressWindowDialog: Dialog;
        finstatransusTxt: Label 'finstatransus', Locked = true;
        finstatransthemTxt: Label 'finstatransthem', locked = true;
        finstatransspecTxt: Label 'finstatransspec', Locked = true;
        amountpostingTxt: Label 'amountposting', Locked = true;
        addressstructTxt: Label 'addressstruct', Locked = true;
        addressunstructTxt: Label 'addressunstruct', Locked = true;
        messageTxt: Label 'message', Locked = true;
        referencesTxt: Label 'references', Locked = true;
        amountTxt: Label 'amount', Locked = true;
        dateTxt: Label 'date', Locked = true;
        textTxt: Label 'text', Locked = true;
        nameTxt: Label 'name', Locked = true;
        address1Txt: Label 'address1', Locked = true;
        address2Txt: Label 'address2', Locked = true;
        address3Txt: Label 'address3', Locked = true;
        address4Txt: Label 'address4', Locked = true;
        zipcodeTxt: Label 'zipcode', Locked = true;
        cityTxt: Label 'city', Locked = true;
        stateTxt: Label 'state', Locked = true;
        countryisocodeTxt: Label 'countryisocode', Locked = true;
        referenceTxt: Label 'reference', Locked = true;
        typeTxt: Label 'type', Locked = true;
        DOCTxt: Label 'DOC', Locked = true;
        PIDTxt: Label 'PID', Locked = true;
        GLBDataExchEntryNo: Integer;
        GLBDataExchLineDefCode: Code[20];
        GLBLineNo: Integer;
        GLBColumnNo: Integer;

    local procedure ProcessImportedStatement(DataExch: Record "Data Exch."; RecordRef: RecordRef)
    var
        FieldBankAccReconciliationLine: record "Bank Acc. Reconciliation Line";
        TempTopLevelXmlBuffer: Record "XML Buffer" temporary;
        TempFinstaUSLevelXmlBuffer: Record "XML Buffer" temporary;
        TempFinstaTHLevelXmlBuffer: Record "XML Buffer" temporary;
        TempFinstaSPLevelXmlBuffer: Record "XML Buffer" temporary;
        TempChildLevelXmlBuffer: Record "XML Buffer" temporary;
        DataExchLineDef: Record "Data Exch. Line Def";
        FinstaRecordRef: RecordRef;
        FinstaInStream: InStream;
        ChildsParentEntryNo: Integer;

    begin
        DataExchLineDef.Get(DataExch."Data Exch. Def Code", DataExch."Data Exch. Line Def Code");
        GLBDataExchEntryNo := DataExch."Entry No.";
        GLBDataExchLineDefCode := DataExchLineDef.Code;
        DataExch.CalcFields("File Content");
        if (DataExch."File Content".HasValue) then begin
            DataExch."File Content".CreateInStream(FinstaInStream);

            Clear(TempTopLevelXmlBuffer);
            Clear(GLBLineNo);
            Clear(GLBColumnNo);
            TempTopLevelXmlBuffer.LoadFromStream(FinstaInStream);

            //Make copies to cycle through xml data
            TempFinstaUSLevelXmlBuffer.Copy(TempTopLevelXmlBuffer, true);
            TempFinstaTHLevelXmlBuffer.Copy(TempTopLevelXmlBuffer, true);
            TempFinstaSPLevelXmlBuffer.Copy(TempTopLevelXmlBuffer, true);
            TempChildLevelXmlBuffer.Copy(TempTopLevelXmlBuffer, true);

            TempFinstaUSLevelXmlBuffer.SetRange(Name, finstatransusTxt);
            if (TempFinstaUSLevelXmlBuffer.FindSet()) then
                repeat
                    FinstaRecordRef := RecordRef.Duplicate();
                    GLBLineNo += 10000;
                    ProgressWindowDialog.Update(1, GLBLineNo);

                    AMCBankingMgt.SetFieldValue(FinstaRecordRef, FieldBankAccReconciliationLine.FieldNo("Statement Line No."), GLBLineNo, false, false);
                    AMCBankingMgt.SetFieldValue(FinstaRecordRef, FieldBankAccReconciliationLine.FieldNo("Data Exch. Line No."), GLBLineNo, false, false);

                    MakeDataExchFieldRecords(TempFinstaUSLevelXmlBuffer);

                    //Get Amountposting tags
                    ChildsParentEntryNo := getChildsParentEntryNo(TempTopLevelXmlBuffer, amountpostingTxt, TempFinstaUSLevelXmlBuffer."Entry No.");
                    getAmountPosting(TempTopLevelXmlBuffer, FinstaRecordRef, ChildsParentEntryNo);

                    //Get addressstruct or tags
                    ChildsParentEntryNo := getChildsParentEntryNo(TempTopLevelXmlBuffer, addressstructTxt, TempFinstaUSLevelXmlBuffer."Entry No.");
                    if (ChildsParentEntryNo <> 0) then
                        getAddressStruct(TempTopLevelXmlBuffer, FinstaRecordRef, ChildsParentEntryNo)
                    else begin
                        ChildsParentEntryNo := getChildsParentEntryNo(TempTopLevelXmlBuffer, addressunstructTxt, TempFinstaUSLevelXmlBuffer."Entry No.");
                        if (ChildsParentEntryNo <> 0) then
                            getAddressUnStruct(TempTopLevelXmlBuffer, FinstaRecordRef, ChildsParentEntryNo);
                    end;

                    //Get message us level
                    getNextLevels(TempChildLevelXmlBuffer, messageTxt, TempFinstaUSLevelXmlBuffer."Entry No.");
                    if (not TempChildLevelXmlBuffer.IsEmpty) then
                        repeat
                            getMessage(TempTopLevelXmlBuffer, FinstaRecordRef, TempChildLevelXmlBuffer."Entry No.");
                        until TempChildLevelXmlBuffer.Next() = 0;

                    //Get references us level
                    getNextLevels(TempChildLevelXmlBuffer, referencesTxt, TempFinstaUSLevelXmlBuffer."Entry No.");
                    if (not TempChildLevelXmlBuffer.IsEmpty) then
                        repeat
                            getReference(TempTopLevelXmlBuffer, FinstaRecordRef, TempChildLevelXmlBuffer."Entry No.");
                        until TempChildLevelXmlBuffer.Next() = 0;

                    //Get th level
                    getNextLevels(TempFinstaTHLevelXmlBuffer, finstatransthemTxt, TempFinstaUSLevelXmlBuffer."Entry No.");
                    if (not TempFinstaTHLevelXmlBuffer.IsEmpty) then
                        repeat
                            //Get message th level
                            getNextLevels(TempChildLevelXmlBuffer, messageTxt, TempFinstaTHLevelXmlBuffer."Entry No.");
                            if (not TempChildLevelXmlBuffer.IsEmpty) then
                                repeat
                                    getMessage(TempTopLevelXmlBuffer, FinstaRecordRef, TempChildLevelXmlBuffer."Entry No.");
                                until TempChildLevelXmlBuffer.Next() = 0;

                            //Get references th level
                            getNextLevels(TempChildLevelXmlBuffer, referencesTxt, TempFinstaTHLevelXmlBuffer."Entry No.");
                            if (not TempChildLevelXmlBuffer.IsEmpty) then
                                repeat
                                    getReference(TempTopLevelXmlBuffer, FinstaRecordRef, TempChildLevelXmlBuffer."Entry No.");
                                until TempChildLevelXmlBuffer.Next() = 0;

                            //Get sp level
                            getNextLevels(TempFinstaSPLevelXmlBuffer, finstatransspecTxt, TempFinstaTHLevelXmlBuffer."Entry No.");
                            if (not TempFinstaSPLevelXmlBuffer.IsEmpty) then
                                repeat
                                    //Get message sp level
                                    getNextLevels(TempChildLevelXmlBuffer, messageTxt, TempFinstaSPLevelXmlBuffer."Entry No.");
                                    if (not TempChildLevelXmlBuffer.IsEmpty) then
                                        repeat
                                            getMessage(TempTopLevelXmlBuffer, FinstaRecordRef, TempChildLevelXmlBuffer."Entry No.");
                                        until TempChildLevelXmlBuffer.Next() = 0;

                                    //Get references sp level
                                    getNextLevels(TempChildLevelXmlBuffer, referencesTxt, TempFinstaSPLevelXmlBuffer."Entry No.");
                                    if (not TempChildLevelXmlBuffer.IsEmpty) then
                                        repeat
                                            getReference(TempTopLevelXmlBuffer, FinstaRecordRef, TempChildLevelXmlBuffer."Entry No.");
                                        until TempChildLevelXmlBuffer.Next() = 0;

                                until TempFinstaSPLevelXmlBuffer.Next() = 0;
                        until TempFinstaTHLevelXmlBuffer.Next() = 0;

                    FinstaRecordRef.Insert();

                until TempFinstaUSLevelXmlBuffer.Next() = 0;

            TempFinstaSPLevelXmlBuffer.DeleteAll();
            TempFinstaTHLevelXmlBuffer.DeleteAll();
            TempFinstaUSLevelXmlBuffer.DeleteAll();
            TempTopLevelXmlBuffer.DeleteAll();
        end;
    end;

    local procedure getNextLevels(var ElementXMLBuffer: Record "XML Buffer"; NextLevelName: Text; ParentEntryNo: Integer)
    var
    begin
        ElementXMLBuffer.Reset();
        ElementXMLBuffer.SetRange("Parent Entry No.", ParentEntryNo);
        ElementXMLBuffer.SetRange(Name, NextLevelName);
        if (ElementXMLBuffer.FindSet()) then;
    end;

    local procedure getAmountPosting(var ElementXMLBuffer: Record "XML Buffer"; RecordRef: RecordRef; ChildsParentEntryNo: Integer)
    var
        BankAccReconciliationLine: record "Bank Acc. Reconciliation Line";
        ChildValue: Text;
    begin
        ChildValue := getChildsValue(ElementXMLBuffer, amountTxt, ChildsParentEntryNo);
        if (ChildValue <> '') then
            AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Statement Amount"), ChildValue, false, true);

        ChildValue := getChildsValue(ElementXMLBuffer, dateTxt, ChildsParentEntryNo);
        if (ChildValue <> '') then
            AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Transaction Date"), ChildValue, false, false);

        ChildValue := getChildsValue(ElementXMLBuffer, textTxt, ChildsParentEntryNo);
        if (ChildValue <> '') then begin
            AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Transaction Text"), ChildValue, true, false);
            AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo(Description), AMCBankingMgt.GetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Transaction Text")), false, false);
        end
    end;

    local procedure getAddressStruct(var ElementXMLBuffer: Record "XML Buffer"; RecordRef: RecordRef; ChildsParentEntryNo: Integer)
    var
        BankAccReconciliationLine: record "Bank Acc. Reconciliation Line";
        NameValue: Text;
        Address1Value: Text;
        Address2Value: Text;
        AddressValue: Text;
    begin
        NameValue := getChildsValue(ElementXMLBuffer, nameTxt, ChildsParentEntryNo);
        Address1Value := getChildsValue(ElementXMLBuffer, address1Txt, ChildsParentEntryNo);
        Address2Value := getChildsValue(ElementXMLBuffer, address2Txt, ChildsParentEntryNo);

        if ((NameValue <> '') or (address1Value <> '') or (Address2Value <> '')) then begin
            if (NameValue <> '') then
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party Name"), NameValue, false, false);

            if (NameValue = '') and (Address1Value <> '') then
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party Name"), Address1Value, false, false)
            else
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party Address"), address1Value, false, false);

            if (address2Value <> '') then
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party Address"), address2Value, true, false);

            AddressValue := getChildsValue(ElementXMLBuffer, zipcodeTxt, ChildsParentEntryNo);
            if (AddressValue <> '') then
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party City"), AddressValue, false, false);

            AddressValue := getChildsValue(ElementXMLBuffer, cityTxt, ChildsParentEntryNo);
            if (AddressValue <> '') then
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party City"), AddressValue, true, false);

            AddressValue := getChildsValue(ElementXMLBuffer, stateTxt, ChildsParentEntryNo);
            if (AddressValue <> '') then
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party City"), AddressValue, true, false);

            AddressValue := getChildsValue(ElementXMLBuffer, countryisocodeTxt, ChildsParentEntryNo);
            if (AddressValue <> '') then
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party City"), AddressValue, true, false);
        end;

    end;

    local procedure getAddressUnStruct(var ElementXMLBuffer: Record "XML Buffer"; RecordRef: RecordRef; ChildsParentEntryNo: Integer)
    var
        BankAccReconciliationLine: record "Bank Acc. Reconciliation Line";
        NameValue: Text;
        Address1Value: Text;
        Address2Value: Text;
        AddressValue: Text;
    begin
        NameValue := getChildsValue(ElementXMLBuffer, nameTxt, ChildsParentEntryNo);
        Address1Value := getChildsValue(ElementXMLBuffer, address1Txt, ChildsParentEntryNo);
        Address2Value := getChildsValue(ElementXMLBuffer, address2Txt, ChildsParentEntryNo);

        if ((NameValue <> '') or (address1Value <> '') or (Address2Value <> '')) then begin
            if (NameValue <> '') then
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party Name"), NameValue, false, false);

            if (NameValue = '') and (Address1Value <> '') then
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party Name"), Address1Value, false, false)
            else
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party Address"), address1Value, false, false);

            if (address2Value <> '') then
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party Address"), address2Value, true, false);

            AddressValue := getChildsValue(ElementXMLBuffer, address3Txt, ChildsParentEntryNo);
            if (AddressValue <> '') then
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party City"), AddressValue, false, false);

            AddressValue := getChildsValue(ElementXMLBuffer, address4Txt, ChildsParentEntryNo);
            if (AddressValue <> '') then
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party City"), AddressValue, true, false);

            AddressValue := getChildsValue(ElementXMLBuffer, countryisocodeTxt, ChildsParentEntryNo);
            if (AddressValue <> '') then
                AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Related-Party City"), AddressValue, true, false);
        end;

    end;

    local procedure getMessage(var ElementXMLBuffer: Record "XML Buffer"; RecordRef: RecordRef; ChildsParentEntryNo: Integer)
    var
        BankAccReconciliationLine: record "Bank Acc. Reconciliation Line";
        MessageValue: Text;
    begin
        MessageValue := getChildsValue(ElementXMLBuffer, textTxt, ChildsParentEntryNo);
        if (MessageValue <> '') then begin
            AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Transaction Text"), MessageValue, true, false);
            AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo(Description), AMCBankingMgt.GetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Transaction Text")), false, false);
        end;
    end;

    local procedure getReference(var ElementXMLBuffer: Record "XML Buffer"; RecordRef: RecordRef; ChildsParentEntryNo: Integer)
    var
        BankAccReconciliationLine: record "Bank Acc. Reconciliation Line";
        TypeValue: Text;
        ReferenceValue: Text;
    begin
        ReferenceValue := getChildsValue(ElementXMLBuffer, referenceTxt, ChildsParentEntryNo);
        TypeValue := getChildsValue(ElementXMLBuffer, typeTxt, ChildsParentEntryNo);
        if ((TypeValue = DOCTxt) or (TypeValue = PIDTxt)) and (ReferenceValue <> '') then
            AMCBankingMgt.SetFieldValue(RecordRef, BankAccReconciliationLine.FieldNo("Additional Transaction Info"), ReferenceValue, true, false);
    end;

    local procedure getChildsParentEntryNo(var ElementXMLBuffer: Record "XML Buffer"; ElementName: Text; ParentEntryNo: Integer): Integer
    var
    begin
        ElementXMLBuffer.Reset();
        ElementXMLBuffer.SetRange("Parent Entry No.", ParentEntryNo);
        ElementXMLBuffer.SetRange(Name, ElementName);
        if (ElementXMLBuffer.FindFirst()) then begin
            MakeDataExchFieldRecords(ElementXMLBuffer);
            exit(ElementXMLBuffer."Entry No.")
        end
        else
            exit(0);
    end;

    local procedure getChildsValue(var ElementXMLBuffer: Record "XML Buffer"; ElementName: Text; ParentEntryNo: Integer): Text
    var
    begin
        ElementXMLBuffer.Reset();
        ElementXMLBuffer.SetRange("Parent Entry No.", ParentEntryNo);
        ElementXMLBuffer.SetRange(Name, ElementName);
        if (ElementXMLBuffer.FindFirst()) then begin
            MakeDataExchFieldRecords(ElementXMLBuffer);
            exit(ElementXMLBuffer.GetValue())
        end
        else
            exit('');
    end;

    local procedure MakeDataExchFieldRecords(var ElementXMLBuffer: Record "XML Buffer")
    var
        DataExchField: Record "Data Exch. Field";
    begin
        if (ElementXMLBuffer.GetValue() <> '') then begin
            GLBColumnNo += 1;
            DataExchField.InsertRecXMLField(GLBDataExchEntryNo, GLBLineNo, GLBColumnNo, ElementXMLBuffer.Path, ElementXMLBuffer.GetValue(), GLBDataExchLineDefCode);
        end;
    end;
}

