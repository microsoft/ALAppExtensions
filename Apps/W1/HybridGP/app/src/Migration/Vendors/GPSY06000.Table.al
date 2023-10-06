namespace Microsoft.DataMigration.GP;

table 40111 "GP SY06000"
{
    Description = 'GP Address Electronic Funds Transfer Master';
    DataClassification = CustomerContent;
    fields
    {
        field(1; SERIES; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; CustomerVendor_ID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(3; ADRSCODE; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(4; VENDORID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(5; CUSTNMBR; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(6; EFTUseMasterID; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(7; EFTBankType; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(8; FRGNBANK; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(9; INACTIVE; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(10; BANKNAME; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(11; EFTBankAcct; Text[35])
        {
            DataClassification = CustomerContent;
        }
        field(12; EFTBankBranch; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(13; GIROPostType; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(14; EFTBankCode; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(15; EFTBankBranchCode; Text[5])
        {
            DataClassification = CustomerContent;
        }
        field(16; EFTBankCheckDigit; Text[3])
        {
            DataClassification = CustomerContent;
        }
        field(17; BSROLLNO; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(18; IntlBankAcctNum; Text[35])
        {
            DataClassification = CustomerContent;
        }
        field(19; SWIFTADDR; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(20; CustVendCountryCode; Text[3])
        {
            DataClassification = CustomerContent;
        }
        field(21; DeliveryCountryCode; Text[3])
        {
            DataClassification = CustomerContent;
        }
        field(22; BNKCTRCD; Text[3])
        {
            DataClassification = CustomerContent;
        }
        field(23; CBANKCD; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(24; ADDRESS1; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(25; ADDRESS2; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(26; ADDRESS3; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(27; ADDRESS4; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(28; RegCode1; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(29; RegCode2; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(30; BankInfo7; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(31; EFTTransitRoutingNo; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(32; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(33; EFTTransferMethod; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(34; EFTAccountType; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(35; EFTPrenoteDate; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(36; EFTTerminationDate; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(37; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; CustomerVendor_ID, ADRSCODE, SERIES)
        {
            Clustered = true;
        }
    }
}