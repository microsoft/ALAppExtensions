codeunit 18081 "GST Purhase No. Series"
{
    //No Series for Purchase
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnpurchaseAfterInsertEvent(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        if not Rec.IsTemporary() then begin
            Record := Rec;
            PostingNoSeries.GetPostingNoSeriesCode(Record);
            Rec := Record;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Buy-from Vendor No.', false, false)]
    local procedure BuyFromVendor(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Buy-from Contact No.', false, false)]
    local procedure BuyfromContactNo(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Pay-to Contact No.', false, false)]
    local procedure PaytoContactNo(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'trading', false, false)]
    local procedure Purchasetrading(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Invoice Type', false, false)]
    local procedure PurchaseInvoiceType(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Location Code', false, false)]
    local procedure PurchaseLocation(var Rec: Record "Purchase Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;
}