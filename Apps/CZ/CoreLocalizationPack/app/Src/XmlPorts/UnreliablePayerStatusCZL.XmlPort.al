xmlport 11759 "Unreliable Payer Status CZL"
{
    Caption = 'Unreliable Payer Status';
    DefaultNamespace = 'http://adis.mfcr.cz/rozhraniCRPDPH/';
    Direction = Import;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    Permissions = tabledata "Unreliable Payer Entry CZL" = rimd;
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
                        if CopyStr(statusText, 1, 2) <> 'OK' then
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
        Temp1UnreliablePayerEntryCZL.Reset();
        if Temp1UnreliablePayerEntryCZL.FindSet() then begin
            if not UnreliablePayerEntryCZL.FindLast() then
                Clear(UnreliablePayerEntryCZL);
            EntryNo := UnreliablePayerEntryCZL."Entry No.";
            repeat
                UnreliablePayerEntryCZL.Reset();
                UnreliablePayerEntryCZL.SetCurrentKey("VAT Registration No.");
                UnreliablePayerEntryCZL.SetRange("VAT Registration No.", Temp1UnreliablePayerEntryCZL."VAT Registration No.");
                UnreliablePayerEntryCZL.SetRange("Entry Type", UnreliablePayerEntryCZL."Entry Type"::Payer);
                if not UnreliablePayerEntryCZL.FindLast() then
                    Clear(UnreliablePayerEntryCZL);

                if (UnreliablePayerEntryCZL."Unreliable Payer" <> Temp1UnreliablePayerEntryCZL."Unreliable Payer") or
                   (UnreliablePayerEntryCZL."Tax Office Number" <> Temp1UnreliablePayerEntryCZL."Tax Office Number")
                then
                    UnreliablePayerEntryCZL."Entry No." := 0;  // new entry

                UnreliablePayerEntryCZL.Init();
                UnreliablePayerEntryCZL."Check Date" := Temp1UnreliablePayerEntryCZL."Check Date";
                UnreliablePayerEntryCZL."Public Date" := Temp1UnreliablePayerEntryCZL."Public Date";
                UnreliablePayerEntryCZL."Unreliable Payer" := Temp1UnreliablePayerEntryCZL."Unreliable Payer";
                UnreliablePayerEntryCZL."VAT Registration No." := Temp1UnreliablePayerEntryCZL."VAT Registration No.";
                UnreliablePayerEntryCZL."Tax Office Number" := Temp1UnreliablePayerEntryCZL."Tax Office Number";
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
                Temp2UnreliablePayerEntryCZL.SetRange("VAT Registration No.", Temp1UnreliablePayerEntryCZL."VAT Registration No.");
                if Temp2UnreliablePayerEntryCZL.FindSet() then
                    repeat
                        UnreliablePayerEntryCZL.Reset();
                        UnreliablePayerEntryCZL.SetCurrentKey("VAT Registration No.");
                        UnreliablePayerEntryCZL.SetRange("VAT Registration No.", Temp2UnreliablePayerEntryCZL."VAT Registration No.");
                        UnreliablePayerEntryCZL.SetRange("Entry Type", UnreliablePayerEntryCZL."Entry Type"::"Bank Account");
                        UnreliablePayerEntryCZL.SetRange("Full Bank Account No.", Temp2UnreliablePayerEntryCZL."Full Bank Account No.");
                        if not UnreliablePayerEntryCZL.FindLast() then
                            Clear(UnreliablePayerEntryCZL);

                        if UnreliablePayerEntryCZL."Bank Account No. Type" <> Temp2UnreliablePayerEntryCZL."Bank Account No. Type" then
                            UnreliablePayerEntryCZL."Entry No." := 0;  // new entry

                        UnreliablePayerEntryCZL.Init();
                        UnreliablePayerEntryCZL."Check Date" := Temp2UnreliablePayerEntryCZL."Check Date";
                        UnreliablePayerEntryCZL."Public Date" := Temp2UnreliablePayerEntryCZL."Public Date";
                        UnreliablePayerEntryCZL."End Public Date" := Temp2UnreliablePayerEntryCZL."End Public Date";
                        UnreliablePayerEntryCZL."VAT Registration No." := Temp2UnreliablePayerEntryCZL."VAT Registration No.";
                        UnreliablePayerEntryCZL."Full Bank Account No." := Temp2UnreliablePayerEntryCZL."Full Bank Account No.";
                        UnreliablePayerEntryCZL."Bank Account No. Type" := Temp2UnreliablePayerEntryCZL."Bank Account No. Type";
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
                    until Temp2UnreliablePayerEntryCZL.Next() = 0;

                if not TempDimensionBuffer.Get(0, 0, Temp1UnreliablePayerEntryCZL."VAT Registration No.") then begin
                    TempDimensionBuffer.Init();
                    TempDimensionBuffer."Table ID" := 0;
                    TempDimensionBuffer."Entry No." := 0;
                    TempDimensionBuffer."Dimension Code" := Temp1UnreliablePayerEntryCZL."VAT Registration No.";
                    TempDimensionBuffer.Insert();
                end;
            until Temp1UnreliablePayerEntryCZL.Next() = 0;

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
        Temp1UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL" temporary;
        Temp2UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL" temporary;
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
        TotalInsertedEntries: Integer;
        UnrPayerElementErr: Label 'Element "nespolehlivyPlatce" format error. Allow values are NE,ANO,NENALEZEN (%1).', Comment = '%1 = ElementValue';
        StatusErr: Label 'Unhandled XML Error (%1).\ Please check the xml file.', Comment = '%1 = StatusText';

    local procedure InsertStatusToBuffer()
    begin
        if dic <> '' then begin
            Temp1UnreliablePayerEntryCZL.Init();
            Temp1UnreliablePayerEntryCZL."Entry No." += 1;
            Temp1UnreliablePayerEntryCZL."Check Date" := TextISOToDate(odpovedGenerovana);
            Temp1UnreliablePayerEntryCZL."Public Date" := TextISOToDate(datumZverejneniNespolehlivosti);
            Temp1UnreliablePayerEntryCZL."Unreliable Payer" := UnrPayerElementToOption(nespolehlivyPlatce);
            Temp1UnreliablePayerEntryCZL."Entry Type" := Temp1UnreliablePayerEntryCZL."Entry Type"::Payer;
            Temp1UnreliablePayerEntryCZL."VAT Registration No." := UnreliablePayerMgtCZL.GetLongVATRegNo(dic);
            Temp1UnreliablePayerEntryCZL."Tax Office Number" := cisloFu;
            Temp1UnreliablePayerEntryCZL.Insert();
        end;
    end;

    local procedure InsertBankAccountToBuffer()
    begin
        if (dic <> '') and ((cisloStandardBA <> '') or (cisloNoStandardBA <> '')) then begin
            Temp2UnreliablePayerEntryCZL.Init();
            Temp2UnreliablePayerEntryCZL."Entry No." += 1;
            Temp2UnreliablePayerEntryCZL."Check Date" := TextISOToDate(odpovedGenerovana);
            Temp2UnreliablePayerEntryCZL."Public Date" := TextISOToDate(datumZverejneni);
            Temp2UnreliablePayerEntryCZL."End Public Date" := TextISOToDate(datumZverejneniUkonceni);
            Temp2UnreliablePayerEntryCZL."Entry Type" := Temp1UnreliablePayerEntryCZL."Entry Type"::"Bank Account";
            Temp2UnreliablePayerEntryCZL."VAT Registration No." := UnreliablePayerMgtCZL.GetLongVATRegNo(dic);
            if cisloStandardBA <> '' then begin
                if predcisli <> '' then
                    Temp2UnreliablePayerEntryCZL."Full Bank Account No." := predcisli + '-';
                Temp2UnreliablePayerEntryCZL."Full Bank Account No." := Temp2UnreliablePayerEntryCZL."Full Bank Account No." +
                  cisloStandardBA + '/' + kodBanky;
            end;
            if cisloNoStandardBA <> '' then begin
                Temp2UnreliablePayerEntryCZL."Full Bank Account No." := cisloNoStandardBA;
                Temp2UnreliablePayerEntryCZL."Bank Account No. Type" := Temp2UnreliablePayerEntryCZL."Bank Account No. Type"::"Not Standard";
            end;
            Temp2UnreliablePayerEntryCZL.Insert();
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
