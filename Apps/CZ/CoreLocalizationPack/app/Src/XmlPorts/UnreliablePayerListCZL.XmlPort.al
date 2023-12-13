xmlport 11760 "Unreliable Payer List CZL"
{
    Caption = 'Unreliable Payer List';
    DefaultNamespace = 'http://adis.mfcr.cz/rozhraniCRPDPH/';
    Direction = Import;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    Permissions = tabledata "Unreliable Payer Entry CZL" = rimd;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(SeznamNespolehlivyPlatceResponse)
        {
            MaxOccurs = Once;
            MinOccurs = Zero;
            textelement(status)
            {
                MaxOccurs = Once;
                MinOccurs = Once;
                textattribute(bezVypisuUctu)
                {
                }
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
                textattribute(datumZverejneniNespolehlivosti)
                {
                    Occurrence = Optional;
                }
                textattribute(nespolehlivyPlatce)
                {
                }
                textattribute(dic)
                {
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
        TempUnreliablePayerEntryCZL.Reset();
        if TempUnreliablePayerEntryCZL.FindSet() then begin
            if not UnreliablePayerEntryCZL.FindLast() then
                Clear(UnreliablePayerEntryCZL);
            EntryNo := UnreliablePayerEntryCZL."Entry No.";
            repeat
                UnreliablePayerEntryCZL.Reset();
                UnreliablePayerEntryCZL.SetCurrentKey("VAT Registration No.");
                UnreliablePayerEntryCZL.SetRange("VAT Registration No.", TempUnreliablePayerEntryCZL."VAT Registration No.");
                UnreliablePayerEntryCZL.SetRange("Entry Type", UnreliablePayerEntryCZL."Entry Type"::Payer);
                if not UnreliablePayerEntryCZL.FindLast() then
                    Clear(UnreliablePayerEntryCZL);

                if (UnreliablePayerEntryCZL."Unreliable Payer" <> TempUnreliablePayerEntryCZL."Unreliable Payer") or
                   (UnreliablePayerEntryCZL."Tax Office Number" <> TempUnreliablePayerEntryCZL."Tax Office Number")
                then
                    UnreliablePayerEntryCZL."Entry No." := 0;  // new entry

                UnreliablePayerEntryCZL.Init();
                UnreliablePayerEntryCZL."Check Date" := TempUnreliablePayerEntryCZL."Check Date";
                UnreliablePayerEntryCZL."Public Date" := TempUnreliablePayerEntryCZL."Public Date";
                UnreliablePayerEntryCZL."Unreliable Payer" := TempUnreliablePayerEntryCZL."Unreliable Payer";
                UnreliablePayerEntryCZL."VAT Registration No." := TempUnreliablePayerEntryCZL."VAT Registration No.";
                UnreliablePayerEntryCZL."Tax Office Number" := TempUnreliablePayerEntryCZL."Tax Office Number";
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
            until TempUnreliablePayerEntryCZL.Next() = 0;
        end;
    end;

    var
        TempUnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL" temporary;
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
        TotalInsertedEntries: Integer;
        UnrPayerElementErr: Label 'Element "nespolehlivyPlatce" format error. Allow values are NE,ANO,NENALEZEN (%1).', Comment = '%1 = ElementValue';
        StatusErr: Label 'Unhandled XML Error (%1).\Please check the xml file.', Comment = '%1 = StatusText';

    local procedure InsertStatusToBuffer()
    begin
        if dic <> '' then begin
            TempUnreliablePayerEntryCZL.Init();
            TempUnreliablePayerEntryCZL."Entry No." += 1;
            TempUnreliablePayerEntryCZL."Check Date" := TextISOToDate(odpovedGenerovana);
            TempUnreliablePayerEntryCZL."Public Date" := TextISOToDate(datumZverejneniNespolehlivosti);
            TempUnreliablePayerEntryCZL."Unreliable Payer" := UnrPayerElementToOption(nespolehlivyPlatce);
            TempUnreliablePayerEntryCZL."Entry Type" := TempUnreliablePayerEntryCZL."Entry Type"::Payer;
            TempUnreliablePayerEntryCZL."VAT Registration No." := UnreliablePayerMgtCZL.GetLongVATRegNo(dic);
            TempUnreliablePayerEntryCZL."Tax Office Number" := cisloFu;
            TempUnreliablePayerEntryCZL.Insert();
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
