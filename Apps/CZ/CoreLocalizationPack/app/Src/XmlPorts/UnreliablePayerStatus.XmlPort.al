xmlport 11759 "Unreliable Payer Status CZL"
{
    Caption = 'Unreliable Payer Status';
    DefaultNamespace = 'http://adis.mfcr.cz/rozhraniCRPDPH/';
    Direction = Import;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    Permissions = TableData "Unreliable Payer Entry CZL" = rimd;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(StatusNespolehlivyPlatceResponse)
        {
            textelement(status)
            {
                MaxOccurs = Once;
                MinOccurs = Once;
                textattribute(statusText)
                {
                    Occurrence = Optional;

                    trigger OnAfterAssignVariable()
                    begin
                        if statusText <> 'OK' then
                            Error(StatusErr, statusText);
                    end;
                }
                textattribute(statusCode)
                {
                    Occurrence = Optional;
                }
                textattribute(odpovedGenerovana)
                {
                    Occurrence = Optional;
                }
            }
            textelement(statusPlatceDPH)
            {
                MinOccurs = Zero;
                textattribute(cisloFu)
                {
                    Occurrence = Optional;
                }
                textattribute(nespolehlivyPlatce)
                {
                }
                textattribute(dic)
                {
                }
                textattribute(datumZverejneniNespolehlivosti)
                {
                    Occurrence = Optional;
                }
                textelement(zverejneneUcty)
                {
                    MinOccurs = Zero;
                    textelement(ucet)
                    {
                        MinOccurs = Zero;
                        textattribute(datumZverejneniUkonceni)
                        {
                            Occurrence = Optional;
                        }
                        textattribute(datumZverejneni)
                        {
                            Occurrence = Required;
                        }
                        textelement(standardniUcet)
                        {
                            MinOccurs = Zero;
                            textattribute(kodBanky)
                            {
                                Occurrence = Optional;
                            }
                            textattribute(cislostandardba)
                            {
                                Occurrence = Optional;
                                XmlName = 'cislo';
                            }
                            textattribute(predcisli)
                            {
                                Occurrence = Optional;
                            }
                            trigger OnAfterAssignVariable()
                            begin
                                InsertBankAccountToBuffer();
                                Clear(cisloStandardBA);
                                Clear(kodBanky);
                                Clear(predcisli);
                                Clear(cisloNoStandardBA);
                            end;
                        }
                        textelement(nestandardniUcet)
                        {
                            MinOccurs = Zero;
                            textattribute(cislonostandardba)
                            {
                                Occurrence = Optional;
                                XmlName = 'cislo';
                            }
                            trigger OnAfterAssignVariable()
                            begin
                                InsertBankAccountToBuffer();
                                Clear(cisloNoStandardBA);
                            end;
                        }
                        trigger OnAfterAssignVariable()
                        begin
                            Clear(datumZverejneni);
                            Clear(datumZverejneniUkonceni);
                        end;
                    }
                }
                trigger OnAfterAssignVariable()
                begin
                    InsertStatusToBuffer();
                    Clear(cisloFu);
                    Clear(datumZverejneniNespolehlivosti);
                    Clear(dic);
                    Clear(nespolehlivyPlatce);
                end;
            }
        }
    }
    trigger OnPostXmlPort()
    var
        EntryNo: Integer;
    begin
        // buffer process
        TempUnreliablePayerEntryCZL1.Reset();
        if TempUnreliablePayerEntryCZL1.FindSet() then begin
            if not UnreliablePayerEntryCZL.FindLast() then
                Clear(UnreliablePayerEntryCZL);
            EntryNo := UnreliablePayerEntryCZL."Entry No.";
            repeat
                UnreliablePayerEntryCZL.Reset();
                UnreliablePayerEntryCZL.SetCurrentKey("VAT Registration No.");
                UnreliablePayerEntryCZL.SetRange("VAT Registration No.", TempUnreliablePayerEntryCZL1."VAT Registration No.");
                UnreliablePayerEntryCZL.SetRange("Entry Type", UnreliablePayerEntryCZL."Entry Type"::Payer);
                if not UnreliablePayerEntryCZL.FindLast() then
                    Clear(UnreliablePayerEntryCZL);

                if (UnreliablePayerEntryCZL."Unreliable Payer" <> TempUnreliablePayerEntryCZL1."Unreliable Payer") or
                   (UnreliablePayerEntryCZL."Tax Office Number" <> TempUnreliablePayerEntryCZL1."Tax Office Number")
                then
                    UnreliablePayerEntryCZL."Entry No." := 0;  // new entry

                UnreliablePayerEntryCZL.Init();
                UnreliablePayerEntryCZL."Check Date" := TempUnreliablePayerEntryCZL1."Check Date";
                UnreliablePayerEntryCZL."Public Date" := TempUnreliablePayerEntryCZL1."Public Date";
                UnreliablePayerEntryCZL."Unreliable Payer" := TempUnreliablePayerEntryCZL1."Unreliable Payer";
                UnreliablePayerEntryCZL."VAT Registration No." := TempUnreliablePayerEntryCZL1."VAT Registration No.";
                UnreliablePayerEntryCZL."Tax Office Number" := TempUnreliablePayerEntryCZL1."Tax Office Number";
                UnreliablePayerEntryCZL."Entry Type" := UnreliablePayerEntryCZL."Entry Type"::Payer;
                UnreliablePayerEntryCZL."Vendor No." := UnreliablePayerMgtCZL.GetVendFromVATRegNo(UnreliablePayerEntryCZL."VAT Registration No.");
                if UnreliablePayerEntryCZL."Entry No." > 0 then
                    UnreliablePayerEntryCZL.Modify()
                else begin
                    EntryNo += 1;
                    UnreliablePayerEntryCZL."Entry No." := EntryNo;
                    UnreliablePayerEntryCZL.Insert();
                    TotalInsertedEntries += 1;
                end;

                // Bank account
                TempUnreliablePayerEntryCZL2.SetRange("VAT Registration No.", TempUnreliablePayerEntryCZL1."VAT Registration No.");
                if TempUnreliablePayerEntryCZL2.FindSet() then
                    repeat
                        UnreliablePayerEntryCZL.Reset();
                        UnreliablePayerEntryCZL.SetCurrentKey("VAT Registration No.");
                        UnreliablePayerEntryCZL.SetRange("VAT Registration No.", TempUnreliablePayerEntryCZL2."VAT Registration No.");
                        UnreliablePayerEntryCZL.SetRange("Entry Type", UnreliablePayerEntryCZL."Entry Type"::"Bank Account");
                        UnreliablePayerEntryCZL.SetRange("Full Bank Account No.", TempUnreliablePayerEntryCZL2."Full Bank Account No.");
                        if not UnreliablePayerEntryCZL.FindLast() then
                            Clear(UnreliablePayerEntryCZL);

                        if UnreliablePayerEntryCZL."Bank Account No. Type" <> TempUnreliablePayerEntryCZL2."Bank Account No. Type" then
                            UnreliablePayerEntryCZL."Entry No." := 0;  // new entry

                        UnreliablePayerEntryCZL.Init();
                        UnreliablePayerEntryCZL."Check Date" := TempUnreliablePayerEntryCZL2."Check Date";
                        UnreliablePayerEntryCZL."Public Date" := TempUnreliablePayerEntryCZL2."Public Date";
                        UnreliablePayerEntryCZL."End Public Date" := TempUnreliablePayerEntryCZL2."End Public Date";
                        UnreliablePayerEntryCZL."VAT Registration No." := TempUnreliablePayerEntryCZL2."VAT Registration No.";
                        UnreliablePayerEntryCZL."Full Bank Account No." := TempUnreliablePayerEntryCZL2."Full Bank Account No.";
                        UnreliablePayerEntryCZL."Bank Account No. Type" := TempUnreliablePayerEntryCZL2."Bank Account No. Type";
                        UnreliablePayerEntryCZL."Entry Type" := UnreliablePayerEntryCZL."Entry Type"::"Bank Account";
                        UnreliablePayerEntryCZL."Vendor No." := UnreliablePayerMgtCZL.GetVendFromVATRegNo(UnreliablePayerEntryCZL."VAT Registration No.");
                        if UnreliablePayerEntryCZL."Entry No." > 0 then
                            UnreliablePayerEntryCZL.Modify()
                        else begin
                            EntryNo += 1;
                            UnreliablePayerEntryCZL."Entry No." := EntryNo;
                            UnreliablePayerEntryCZL.Insert();
                            TotalInsertedEntries += 1;
                        end;
                    until TempUnreliablePayerEntryCZL2.Next() = 0;

                if not TempDimensionBuffer.Get(0, 0, TempUnreliablePayerEntryCZL1."VAT Registration No.") then begin
                    TempDimensionBuffer.Init();
                    TempDimensionBuffer."Table ID" := 0;
                    TempDimensionBuffer."Entry No." := 0;
                    TempDimensionBuffer."Dimension Code" := TempUnreliablePayerEntryCZL1."VAT Registration No.";
                    TempDimensionBuffer.Insert();
                end;
            until TempUnreliablePayerEntryCZL1.Next() = 0;

            // end public bank account update - this records not in actual xml file!
            if TempDimensionBuffer.FindSet() then
                repeat
                    UnreliablePayerEntryCZL.Reset();
                    UnreliablePayerEntryCZL.SetCurrentKey("VAT Registration No.");
                    UnreliablePayerEntryCZL.SetRange("VAT Registration No.", TempDimensionBuffer."Dimension Code");
                    UnreliablePayerEntryCZL.SetRange("Entry Type", UnreliablePayerEntryCZL."Entry Type"::"Bank Account");
                    UnreliablePayerEntryCZL.SetFilter("Check Date", '<>%1', TextISOToDate(odpovedGenerovana));
                    if UnreliablePayerEntryCZL.FindSet() then
                        repeat
                            if UnreliablePayerEntryCZL."End Public Date" = 0D then begin
                                UnreliablePayerEntryCZL."End Public Date" := TextISOToDate(odpovedGenerovana) - 1;
                                UnreliablePayerEntryCZL.Modify();
                            end;
                        until UnreliablePayerEntryCZL.Next() = 0;
                until TempDimensionBuffer.Next() = 0;
        end;
    end;

    var
        TempUnreliablePayerEntryCZL1: Record "Unreliable Payer Entry CZL" temporary;
        TempUnreliablePayerEntryCZL2: Record "Unreliable Payer Entry CZL" temporary;
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
        TotalInsertedEntries: Integer;
        UnrPayerElementErr: Label 'Element "nespolehlivyPlatce" format error. Allow values are NE,ANO,NENALEZEN (%1).', Comment = '%1 = ElementValue';
        StatusErr: Label 'Unhandled XML Error (%1).\ Please check the xml file.', Comment = '%1 = StatusText';

    local procedure InsertStatusToBuffer()
    begin
        if dic <> '' then begin
            TempUnreliablePayerEntryCZL1.Init();
            TempUnreliablePayerEntryCZL1."Entry No." += 1;
            TempUnreliablePayerEntryCZL1."Check Date" := TextISOToDate(odpovedGenerovana);
            TempUnreliablePayerEntryCZL1."Public Date" := TextISOToDate(datumZverejneniNespolehlivosti);
            TempUnreliablePayerEntryCZL1."Unreliable Payer" := UnrPayerElementToOption(nespolehlivyPlatce);
            TempUnreliablePayerEntryCZL1."Entry Type" := TempUnreliablePayerEntryCZL1."Entry Type"::Payer;
            TempUnreliablePayerEntryCZL1."VAT Registration No." := UnreliablePayerMgtCZL.GetLongVATRegNo(dic);
            TempUnreliablePayerEntryCZL1."Tax Office Number" := cisloFu;
            TempUnreliablePayerEntryCZL1.Insert();
        end;
    end;

    local procedure InsertBankAccountToBuffer()
    begin
        if (dic <> '') and ((cisloStandardBA <> '') or (cisloNoStandardBA <> '')) then begin
            TempUnreliablePayerEntryCZL2.Init();
            TempUnreliablePayerEntryCZL2."Entry No." += 1;
            TempUnreliablePayerEntryCZL2."Check Date" := TextISOToDate(odpovedGenerovana);
            TempUnreliablePayerEntryCZL2."Public Date" := TextISOToDate(datumZverejneni);
            TempUnreliablePayerEntryCZL2."End Public Date" := TextISOToDate(datumZverejneniUkonceni);
            TempUnreliablePayerEntryCZL2."Entry Type" := TempUnreliablePayerEntryCZL1."Entry Type"::"Bank Account";
            TempUnreliablePayerEntryCZL2."VAT Registration No." := UnreliablePayerMgtCZL.GetLongVATRegNo(dic);
            if cisloStandardBA <> '' then begin
                if predcisli <> '' then
                    TempUnreliablePayerEntryCZL2."Full Bank Account No." := predcisli + '-';
                TempUnreliablePayerEntryCZL2."Full Bank Account No." := TempUnreliablePayerEntryCZL2."Full Bank Account No." +
                  cisloStandardBA + '/' + kodBanky;
            end;
            if cisloNoStandardBA <> '' then begin
                TempUnreliablePayerEntryCZL2."Full Bank Account No." := cisloNoStandardBA;
                TempUnreliablePayerEntryCZL2."Bank Account No. Type" := TempUnreliablePayerEntryCZL2."Bank Account No. Type"::"Not Standard";
            end;
            TempUnreliablePayerEntryCZL2.Insert();
        end;
    end;

    procedure GetInsertEntryCount(): Integer
    begin
        exit(TotalInsertedEntries);
    end;

    local procedure TextISOToDate(Text: Text[30]): Date
    var
        YY: Integer;
        MM: Integer;
        DD: Integer;
    begin
        if Evaluate(DD, CopyStr(Text, 9, 2)) then
            if Evaluate(MM, CopyStr(Text, 6, 2)) then
                if Evaluate(YY, CopyStr(Text, 1, 4)) then
                    if (YY > 1754) and (MM <> 0) and (DD <> 0) then
                        exit(DMY2Date(DD, MM, YY));
    end;

    local procedure UnrPayerElementToOption(UnrPayerElementValue: Text[30]) ReturnValue: Integer
    begin
        case UpperCase(UnrPayerElementValue) of
            'NE':
                ReturnValue := 1;
            'ANO':
                ReturnValue := 2;
            'NENALEZEN':
                ReturnValue := 3;
            else
                Error(UnrPayerElementErr, UnrPayerElementValue);
        end;
    end;
}
