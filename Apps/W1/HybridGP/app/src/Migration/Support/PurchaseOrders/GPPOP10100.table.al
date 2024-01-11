namespace Microsoft.DataMigration.GP;

table 40137 "GP POP10100"
{
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; PONUMBER; Text[18])
        {
            Caption = 'PONUMBER';
            DataClassification = CustomerContent;
        }
        field(2; POSTATUS; Option)
        {
            Caption = 'POSTATUS';
            OptionMembers = ,"New","Released","Change Order","Received","Closed","Canceled";
            DataClassification = CustomerContent;
        }
        field(3; STATGRP; Integer)
        {
            Caption = 'STATGRP';
            DataClassification = CustomerContent;
        }
        field(4; POTYPE; Option)
        {
            Caption = 'POTYPE';
            OptionMembers = ,"Standard","Drop-Ship","Blanket","Drop-Ship Blanket";
            DataClassification = CustomerContent;
        }
        field(7; DOCDATE; Date)
        {
            Caption = 'DOCDATE';
            DataClassification = CustomerContent;
        }
        field(10; PRMDATE; Date)
        {
            Caption = 'PRMDATE';
            DataClassification = CustomerContent;
        }
        field(14; SHIPMTHD; Text[16])
        {
            Caption = 'SHIPMTHD';
            DataClassification = CustomerContent;
        }
        field(22; VENDORID; Text[16])
        {
            Caption = 'VENDORID';
            DataClassification = CustomerContent;
        }
        field(28; PRSTADCD; Text[16])
        {
            Caption = 'PRSTADCD';
            DataClassification = CustomerContent;
        }
        field(29; CMPNYNAM; Text[66])
        {
            Caption = 'CMPNYNAM';
            DataClassification = CustomerContent;
        }
        field(30; CONTACT; Text[62])
        {
            Caption = 'CONTACT';
            DataClassification = CustomerContent;
        }
        field(31; ADDRESS1; Text[62])
        {
            Caption = 'ADDRESS1';
            DataClassification = CustomerContent;
        }
        field(32; ADDRESS2; Text[62])
        {
            Caption = 'ADDRESS2';
            DataClassification = CustomerContent;
        }
        field(34; CITY; Text[36])
        {
            Caption = 'CITY';
            DataClassification = CustomerContent;
        }
        field(35; STATE; Text[30])
        {
            Caption = 'STATE';
            DataClassification = CustomerContent;
        }
        field(36; ZIPCODE; Text[12])
        {
            Caption = 'ZIPCODE';
            DataClassification = CustomerContent;
        }
        field(38; COUNTRY; Text[62])
        {
            Caption = 'COUNTRY';
            DataClassification = CustomerContent;
        }
        field(43; PYMTRMID; Text[22])
        {
            Caption = 'PYMTRMID';
            DataClassification = CustomerContent;
        }
        field(54; PONOTIDS_1; Decimal)
        {
            Caption = 'PO Note Index';
            DataClassification = CustomerContent;
        }
        field(55; PONOTIDS_2; Decimal)
        {
            Caption = 'Buyer Note Index';
            DataClassification = CustomerContent;
        }
        field(56; PONOTIDS_3; Decimal)
        {
            Caption = 'Vendor ID Index';
            DataClassification = CustomerContent;
        }
        field(57; PONOTIDS_4; Decimal)
        {
            Caption = 'Comment Note Index';
            DataClassification = CustomerContent;
        }
        field(58; PONOTIDS_5; Decimal)
        {
            Caption = 'Payment Term ID Note Index';
            DataClassification = CustomerContent;
        }
        field(59; PONOTIDS_6; Decimal)
        {
            Caption = 'Shipping Method Note Index';
            DataClassification = CustomerContent;
        }
        field(60; PONOTIDS_7; Decimal)
        {
            Caption = 'Currency ID Index';
            DataClassification = CustomerContent;
        }
        field(61; PONOTIDS_8; Decimal)
        {
            Caption = 'Tax Schedule Index';
            DataClassification = CustomerContent;
        }
        field(62; PONOTIDS_9; Decimal)
        {
            Caption = 'Freight Tax Schedule Index';
            DataClassification = CustomerContent;
        }
        field(63; PONOTIDS_10; Decimal)
        {
            Caption = 'Misc Tax Schedule Index';
            DataClassification = CustomerContent;
        }
        field(64; PONOTIDS_11; Decimal)
        {
            Caption = 'Contract Number Index';
            DataClassification = CustomerContent;
        }
        field(71; CURNCYID; Text[16])
        {
            Caption = 'CURNCYID';
            DataClassification = CustomerContent;
        }
        field(72; CURRNIDX; Integer)
        {
            Caption = 'CURRNIDX';
            DataClassification = CustomerContent;
        }
        field(73; RATETPID; Text[16])
        {
            Caption = 'RATETPID';
            DataClassification = CustomerContent;
        }
        field(74; EXGTBLID; Text[16])
        {
            Caption = 'EXGTBLID';
            DataClassification = CustomerContent;
        }
        field(75; XCHGRATE; Decimal)
        {
            Caption = 'XCHGRATE';
            DataClassification = CustomerContent;
        }
        field(76; EXCHDATE; Date)
        {
            Caption = 'EXCHDATE';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PONUMBER)
        {
            Clustered = true;
        }
    }

    internal procedure GetRecordNotesText(var RecordNotesTxt: Text; var RecordNoteDate: Date): Boolean
    var
        HelperFunctions: Codeunit "Helper Functions";
        NoteTextBuilder: TextBuilder;
        EntryNoteTxt: Text;
    begin
        RecordNoteDate := Today();

        if HelperFunctions.GetRecordNoteDetails(Rec.PONOTIDS_1, EntryNoteTxt, RecordNoteDate) then
            NoteTextBuilder.AppendLine('[PO] - ' + EntryNoteTxt);

        if HelperFunctions.GetRecordNoteDetails(Rec.PONOTIDS_2, EntryNoteTxt, RecordNoteDate) then
            NoteTextBuilder.AppendLine('[Buyer] - ' + EntryNoteTxt);

        if HelperFunctions.GetRecordNoteDetails(Rec.PONOTIDS_3, EntryNoteTxt, RecordNoteDate) then
            NoteTextBuilder.AppendLine('[Vendor Id] - ' + EntryNoteTxt);

        if HelperFunctions.GetRecordNoteDetails(Rec.PONOTIDS_4, EntryNoteTxt, RecordNoteDate) then
            NoteTextBuilder.AppendLine('[Comment] - ' + EntryNoteTxt);

        if HelperFunctions.GetRecordNoteDetails(Rec.PONOTIDS_5, EntryNoteTxt, RecordNoteDate) then
            NoteTextBuilder.AppendLine('[Payment Term Id] - ' + EntryNoteTxt);

        if HelperFunctions.GetRecordNoteDetails(Rec.PONOTIDS_6, EntryNoteTxt, RecordNoteDate) then
            NoteTextBuilder.AppendLine('[Shipping Method] - ' + EntryNoteTxt);

        if HelperFunctions.GetRecordNoteDetails(Rec.PONOTIDS_7, EntryNoteTxt, RecordNoteDate) then
            NoteTextBuilder.AppendLine('[Currency Id] - ' + EntryNoteTxt);

        if HelperFunctions.GetRecordNoteDetails(Rec.PONOTIDS_8, EntryNoteTxt, RecordNoteDate) then
            NoteTextBuilder.AppendLine('[Tax Schedule] - ' + EntryNoteTxt);

        if HelperFunctions.GetRecordNoteDetails(Rec.PONOTIDS_9, EntryNoteTxt, RecordNoteDate) then
            NoteTextBuilder.AppendLine('[Freight Tax] - ' + EntryNoteTxt);

        if HelperFunctions.GetRecordNoteDetails(Rec.PONOTIDS_10, EntryNoteTxt, RecordNoteDate) then
            NoteTextBuilder.AppendLine('[Misc. Tax] - ' + EntryNoteTxt);

        if HelperFunctions.GetRecordNoteDetails(Rec.PONOTIDS_11, EntryNoteTxt, RecordNoteDate) then
            NoteTextBuilder.AppendLine('[Contract Number] - ' + EntryNoteTxt);

        RecordNotesTxt := NoteTextBuilder.ToText();

        if RecordNotesTxt = '' then
            exit(false);

        exit(true);
    end;
}