codeunit 148057 "SAF-T Modification DK Tests"
{
    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] [Audit File Export] [SAF-T] [SAF-T Modification DK]
    end;

    [Test]
    procedure TestGetStandardAccountsCSVForFourDigitStandardAccount()
    var
        StandardAccount: Record "Standard Account";
        AuditFileExportSetup: Record "Audit File Export Setup";
        CreateStandardDataSAFTDK: Codeunit "Create Standard Data SAF-T DK";
        Assert: Codeunit "Assert";
        StandardAccountType: Enum "Standard Account Type";
        ExpectedAccounts: Dictionary of [Text, Text];
        Result: Boolean;
        AccountNo: Text;
    begin
        // [FEATURE] [AI test]
        // [FEATURE] [RegF][DK] New Standard Chart of Accounts 2025
        // [SCENARIO] LoadStandardAccounts loads correct standard accounts for Four Digit Standard Account

        // [GIVEN] Standard Account Type is "Four Digit Standard Account"
        StandardAccountType := StandardAccountType::"Four Digit Standard Account";
        StandardAccount.DeleteAll();
        AuditFileExportSetup.DeleteAll();
        AuditFileExportSetup.Init();
        AuditFileExportSetup."Standard Account Type" := StandardAccountType;
        AuditFileExportSetup.Insert();

        // [GIVEN] Expected standard accounts (sample from beginning, middle, and end)
        ExpectedAccounts.Add('1010', 'Salg af varer og ydelser');
        ExpectedAccounts.Add('1050', 'Salg af varer udland, EU');
        ExpectedAccounts.Add('1100', 'Salg af varer udland, ikke-EU');
        ExpectedAccounts.Add('2850', 'Lønninger');
        ExpectedAccounts.Add('3000', 'Af- og nedskrivninger af erhvervede immaterielle anlægsaktiver');
        ExpectedAccounts.Add('5010', 'Goodwill, bogført værdi primo');
        ExpectedAccounts.Add('6000', 'Andre værdipapirer og kapitalandele');
        ExpectedAccounts.Add('7010', 'Hensættelser til udskudt skat');
        ExpectedAccounts.Add('8040', 'Øvrig anden gæld');
        ExpectedAccounts.Add('8070', 'Periodeafgrænsningsposter');
        ExpectedAccounts.Add('8080', 'Periodeafgrænsningsposter');

        // [WHEN] LoadStandardAccounts is called
        Result := CreateStandardDataSAFTDK.LoadStandardAccounts(StandardAccountType);

        // [THEN] The method returns true
        Assert.IsTrue(Result, 'LoadStandardAccounts should return true.');

        // [THEN] Standard Accounts are loaded correctly
        StandardAccount.SetRange(Type, StandardAccountType);
        Assert.RecordCount(StandardAccount, 335);
        Assert.RecordIsNotEmpty(StandardAccount);
        foreach AccountNo in ExpectedAccounts.Keys do begin
            StandardAccount.Get(StandardAccountType, '', AccountNo);
            Assert.AreEqual(ExpectedAccounts.Get(AccountNo), StandardAccount.Description, 'Account ' + AccountNo + ' description is incorrect.');
        end;
    end;

    [Test]
    procedure TestGetStandardAccountsCSVForStandardAccountsDecember2025()
    var
        StandardAccount: Record "Standard Account";
        AuditFileExportSetup: Record "Audit File Export Setup";
        CreateStandardDataSAFTDK: Codeunit "Create Standard Data SAF-T DK";
        Assert: Codeunit "Assert";
        StandardAccountType: Enum "Standard Account Type";
        ExpectedAccounts: Dictionary of [Text, Text];
        Result: Boolean;
        AccountNo: Text;
    begin
        // [FEATURE] [AI test]
        // [FEATURE] [RegF][DK] New Standard Chart of Accounts 2025
        // [SCENARIO] LoadStandardAccounts loads correct standard accounts for Standard Account 2025

        // [GIVEN] Standard Account Type is "Standard Account 2025"
        StandardAccountType := StandardAccountType::"Standard Account 2025";
        StandardAccount.DeleteAll();
        AuditFileExportSetup.DeleteAll();
        AuditFileExportSetup.Init();
        AuditFileExportSetup."Standard Account Type" := StandardAccountType;
        AuditFileExportSetup.Insert();

        // [GIVEN] Expected standard accounts (sample from beginning, middle, and end)
        ExpectedAccounts.Add('1010', 'Salg af varer og ydelser');
        ExpectedAccounts.Add('1050', 'Salg af varer udland, EU');
        ExpectedAccounts.Add('1100', 'Salg af varer udland, ikke-EU');
        ExpectedAccounts.Add('1210', 'Salgsrabatter');
        ExpectedAccounts.Add('2845', 'AM Bidragspligtig A-Indkomst');
        ExpectedAccounts.Add('3000', 'Af- og nedskrivninger af erhvervede immaterielle anlægsaktiver');
        ExpectedAccounts.Add('5010', 'Færdiggjort udviklingsprojekter, herunder patenter og lignende rettigheder, der stammer fra udviklingsprojekter, Kostpris primo');
        ExpectedAccounts.Add('6000', 'Andre værdipapirer og kapitalandele');
        ExpectedAccounts.Add('7010', 'Hensættelser til udskudt skat');
        ExpectedAccounts.Add('8040', 'Øvrig anden gæld');
        ExpectedAccounts.Add('9999', 'PASSIVER I ALT');

        // [WHEN] LoadStandardAccounts is called
        Result := CreateStandardDataSAFTDK.LoadStandardAccounts(StandardAccountType);

        // [THEN] The method returns true
        Assert.IsTrue(Result, 'LoadStandardAccounts should return true.');

        // [THEN] Standard Accounts are loaded correctly
        StandardAccount.SetRange(Type, StandardAccountType);
        Assert.RecordCount(StandardAccount, 604);
        Assert.RecordIsNotEmpty(StandardAccount);
        foreach AccountNo in ExpectedAccounts.Keys do begin
            StandardAccount.Get(StandardAccountType, '', AccountNo);
            Assert.AreEqual(ExpectedAccounts.Get(AccountNo), StandardAccount.Description, 'Account ' + AccountNo + ' description is incorrect.');
        end;
    end;

    [Test]
    procedure TestLoadStandardTaxCodesForFourDigitStandardAccount()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        VATReportingCode: Record "VAT Reporting Code";
        CreateStandardDataSAFTDK: Codeunit "Create Standard Data SAF-T DK";
        Assert: Codeunit Assert;
        StandardAccountType: Enum "Standard Account Type";
        ExpectedTaxCodes: Dictionary of [Text, Text];
        Result: Boolean;
        TaxCode: Text;
    begin
        // [FEATURE] [AI test]
        // [FEATURE] [RegF][DK] New Standard Chart of Accounts 2025
        // [SCENARIO] LoadStandardTaxCodes loads correct tax codes for Four Digit Standard Account

        // [GIVEN] Audit File Export Setup with "Four Digit Standard Account"
        AuditFileExportSetup.DeleteAll();
        VATReportingCode.DeleteAll();
        AuditFileExportSetup.Init();
        AuditFileExportSetup."Standard Account Type" := StandardAccountType::"Four Digit Standard Account";
        AuditFileExportSetup.Insert();

        // [GIVEN] Expected tax codes and descriptions
        ExpectedTaxCodes.Add('S1', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('S0', 'Skal som udgangspunkt medtages i rubrik C, hvis feks. skibe i udenrigsfart, salg af aviser');
        ExpectedTaxCodes.Add('S%', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('SMF', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('Sbrugt', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('Smargin', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('Smotor', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('Sleasing', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('Skunstnere', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('Slokal', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('S2', 'Rubrik B - varer');
        ExpectedTaxCodes.Add('S7', 'Rubrik B - oplysninger, der ikke skal indberettes til "EU-salg uden moms"');
        ExpectedTaxCodes.Add('S3', 'Rubrik B - ydelser');
        ExpectedTaxCodes.Add('SMFEU', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('S4', 'Rubrik C - eksport udenfor EU');
        ExpectedTaxCodes.Add('S5', 'Rubrik C - eksport udenfor EU');
        ExpectedTaxCodes.Add('S6', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('K1', 'Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K3', 'Købsmoms (indgående moms - skønsmæssig andel)');
        ExpectedTaxCodes.Add('K0', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('K7', 'Købsmoms (indgående moms 66,6%)');
        ExpectedTaxCodes.Add('K5A', 'Købsmoms (indgående moms 50%)');
        ExpectedTaxCodes.Add('K5B', 'Købsmoms (indgående moms 50% af "pro rata")');
        ExpectedTaxCodes.Add('KL1', 'Købsmoms (indgående moms 33,3%)');
        ExpectedTaxCodes.Add('K25A', 'Købsmoms (indgående moms 25%)');
        ExpectedTaxCodes.Add('K25B', 'Købsmoms (indgående moms 25% af "pro rata")');
        ExpectedTaxCodes.Add('KL2', 'Købsmoms (indgående moms - faktura fradrag)');
        ExpectedTaxCodes.Add('KL3', 'Købsmoms (indgående moms - faktura pro rata fradrag)');
        ExpectedTaxCodes.Add('K2', 'Købsmoms (indgående moms - omsætningsfordeling)');
        ExpectedTaxCodes.Add('K6', 'Købsmoms (indgående moms - omsætningsfordeling i sektoren)');
        ExpectedTaxCodes.Add('K4', 'Købsmoms (indgående moms - forholdsmæssig andel)');
        ExpectedTaxCodes.Add('K-brugtmoms', 'Indgår i særligt beregningsgrundlag');
        ExpectedTaxCodes.Add('K-marginmoms', 'Indgår i særligt beregningsgrundlag');
        ExpectedTaxCodes.Add('K-brugtbil', 'Indgår i særligt beregningsgrundlag');
        ExpectedTaxCodes.Add('K-leasingbil', 'Indgår i særligt beregningsgrundlag');
        ExpectedTaxCodes.Add('K-DK0-1', 'Salgsmoms (udgående) og købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K-DKO-2', 'Salgsmoms og købsmoms ( indgående moms omsætningsfordeling)');
        ExpectedTaxCodes.Add('K-DKO-3', 'Salgsmoms og købsmoms (indgående moms skønsmæssig andel)');
        ExpectedTaxCodes.Add('K-DKO-0', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('K-DKO-4', 'Salgsmoms og købsmoms ( indgående moms arealfordeling)');
        ExpectedTaxCodes.Add('K-LokalMoms', 'Tilbagesøgning efter refusionsordningsreglerne');
        ExpectedTaxCodes.Add('K-DKO-I', 'Refusionsordning');
        ExpectedTaxCodes.Add('K-EU-V-1', 'Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K-EU-V-3', 'Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - skønsmæssig andel)');
        ExpectedTaxCodes.Add('K-EU-V-0', 'Moms af varekøb i udlandet (både EU og lande uden for EU)');
        ExpectedTaxCodes.Add('K-EU-V-2', 'Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - omsætningsfordeling)');
        ExpectedTaxCodes.Add('K-EU-V-4', 'Moms af varekøb i udlandet (både EU og lande uden for EU)  samt Købsmoms (indgående moms - forholdsmæssig andel)');
        ExpectedTaxCodes.Add('K-EU-Y-1', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K-EU-Y-3', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - skønsmæssig andel)');
        ExpectedTaxCodes.Add('K-EU-Y-0', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt');
        ExpectedTaxCodes.Add('K-EU-Y-2', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - omsætningsfordeling)');
        ExpectedTaxCodes.Add('K-EU-Y-4', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - forholdsmæssig andel)');
        ExpectedTaxCodes.Add('KL-EU-2', 'Købsmoms (indgående moms - faktura fradrag)');
        ExpectedTaxCodes.Add('KL-EU-3', 'Købsmoms (indgående moms - faktura pro rata fradrag)');
        ExpectedTaxCodes.Add('K-EU-Y-L1', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt samt Købsmoms (indgående moms 33,3%)');
        ExpectedTaxCodes.Add('K-EU-MF', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('K-%EU-V-1', 'Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K-%EU-V-3', 'Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - skønsmæssig andel)');
        ExpectedTaxCodes.Add('K-%EU-V-0', 'Moms af varekøb i udlandet (både EU og lande uden for EU)');
        ExpectedTaxCodes.Add('K-%EU-V-2', 'Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - omsætningsfordeling)');
        ExpectedTaxCodes.Add('K-%EU-V-4', 'Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - forholdsmæssig andel)');
        ExpectedTaxCodes.Add('K-%EU-Y-1', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K-%EU-Y-3', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - skønsmæssig andel)');
        ExpectedTaxCodes.Add('K-%EU-Y-0', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt');
        ExpectedTaxCodes.Add('K-%EU-Y-2', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - omsætningsfordeling)');
        ExpectedTaxCodes.Add('K-%EU-Y-4', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - forholdsmæssig andel)');

        // [WHEN] LoadStandardTaxCodes is called
        Result := CreateStandardDataSAFTDK.LoadStandardTaxCodes();

        // [THEN] The method returns true
        Assert.IsTrue(Result, 'LoadStandardTaxCodes should return true.');

        // [THEN] VAT Reporting Codes are loaded correctly
        foreach TaxCode in ExpectedTaxCodes.Keys do begin
            VATReportingCode.Get(TaxCode);
            Assert.AreEqual(ExpectedTaxCodes.Get(TaxCode), VATReportingCode.Description, 'Tax code ' + TaxCode + ' description is incorrect.');
        end;
    end;

    [Test]
    procedure TestLoadStandardTaxCodesForStandardAccount2025()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        VATReportingCode: Record "VAT Reporting Code";
        CreateStandardDataSAFTDK: Codeunit "Create Standard Data SAF-T DK";
        Assert: Codeunit Assert;
        StandardAccountType: Enum "Standard Account Type";
        ExpectedTaxCodes: Dictionary of [Text, Text];
        Result: Boolean;
        TaxCode: Text;
    begin
        // [FEATURE] [AI test]
        // [FEATURE] [RegF][DK] New Standard Chart of Accounts 2025
        // [SCENARIO] LoadStandardTaxCodes loads correct tax codes for Standard Account 2025

        // [GIVEN] Audit File Export Setup with "Standard Account 2025"
        AuditFileExportSetup.DeleteAll();
        VATReportingCode.DeleteAll();
        AuditFileExportSetup.Init();
        AuditFileExportSetup."Standard Account Type" := StandardAccountType::"Standard Account 2025";
        AuditFileExportSetup.Insert();

        // [GIVEN] Expected tax codes and descriptions for 2025
        ExpectedTaxCodes.Add('S01', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('S02', 'Skal som udgangspunkt medtages i rubrik C, hvis feks. skibe i udenrigsfart, salg af aviser');
        ExpectedTaxCodes.Add('S81', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('S82', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('S83', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('S84', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('S85', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('S86', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('S87', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('S88', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('S21', 'Rubrik B - varer');
        ExpectedTaxCodes.Add('S22', 'Rubrik B - oplysninger, der ikke skal indberettes til "EU-salg uden moms"');
        ExpectedTaxCodes.Add('S23', 'Rubrik B - ydelser');
        ExpectedTaxCodes.Add('S24', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('S25', 'Skal ikke medtages på momsangivelsen, men som trekantshandel på EU-salgsangivelsen');
        ExpectedTaxCodes.Add('S41', 'Rubrik C - eksport udenfor EU.');
        ExpectedTaxCodes.Add('S42', 'Rubrik C - eksport udenfor EU.');
        ExpectedTaxCodes.Add('S43', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('S61', 'OSS angivelsen + momsangivelsens rubrik C');
        ExpectedTaxCodes.Add('S62', 'OSS angivelsen + Rubrik B - oplysninger der ikke skal indberettes til "EU-salg uden moms"');
        ExpectedTaxCodes.Add('S63', 'OSS angivelsen + Rubrik C');
        ExpectedTaxCodes.Add('S64', 'OSS angivelsen (skal ikke angives på momsangivelsen)');
        ExpectedTaxCodes.Add('S65', 'OSS angivelsen + rubrik A  - varer');
        ExpectedTaxCodes.Add('K010', 'Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K020', 'Købsmoms (indgående moms - skønsmæssig andel)');
        ExpectedTaxCodes.Add('K030', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('K610', 'Købsmoms (indgående moms 66,6%)');
        ExpectedTaxCodes.Add('K040', 'Købsmoms (indgående moms 50%)');
        ExpectedTaxCodes.Add('K050', 'Købsmoms (indgående moms 50% af "pro rata")');
        ExpectedTaxCodes.Add('K060', 'Købsmoms (indgående moms 33,3%)');
        ExpectedTaxCodes.Add('K070', 'Købsmoms (indgående moms 25%)');
        ExpectedTaxCodes.Add('K080', 'Købsmoms (indgående moms 25% af "pro rata")');
        ExpectedTaxCodes.Add('K090', 'Købsmoms (indgående moms - faktura fradrag)');
        ExpectedTaxCodes.Add('K100', 'Købsmoms (indgående moms - faktura pro rata fradrag)');
        ExpectedTaxCodes.Add('K110', 'Købsmoms (indgående moms - omsætningsfordeling)');
        ExpectedTaxCodes.Add('K120', 'Købsmoms (indgående moms - omsætningsfordeling i sektoren)');
        ExpectedTaxCodes.Add('K130', 'Købsmoms (indgående moms - forholdsmæssig andel)');
        ExpectedTaxCodes.Add('K620', 'Indgår i særligt beregningsgrundlag');
        ExpectedTaxCodes.Add('K630', 'Indgår i særligt beregningsgrundlag');
        ExpectedTaxCodes.Add('K640', 'Indgår i særligt beregningsgrundlag');
        ExpectedTaxCodes.Add('K650', 'Indgår i særligt beregningsgrundlag');
        ExpectedTaxCodes.Add('K660', 'Salgsmoms (udgående) og købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K670', 'Salgsmoms og købsmoms ( indgående moms omsætningsfordeling)');
        ExpectedTaxCodes.Add('K680', 'Salgsmoms og købsmoms (indgående moms skønsmæssig andel)');
        ExpectedTaxCodes.Add('K690', 'Salgsmoms (udgående moms)');
        ExpectedTaxCodes.Add('K700', 'Salgsmoms og købsmoms ( indgående moms arealfordeling)');
        ExpectedTaxCodes.Add('K710', 'Tilbagesøgning efter refusionsordningsreglerne');
        ExpectedTaxCodes.Add('K720', 'Angives ikke på momsangivelsen - indgår i opgørelsen ved refusionsordning');
        ExpectedTaxCodes.Add('K210', 'Varer + Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K220', 'Varer + Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K230', 'Varer + Moms af varekøb i udlandet (både EU og lande uden for EU)');
        ExpectedTaxCodes.Add('K240', 'Varer + Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K250', 'Varer + Moms af varekøb i udlandet (både EU og lande uden for EU)  samt Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K260', 'Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K270', 'Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K280', 'Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt');
        ExpectedTaxCodes.Add('K290', 'Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - omsætningsfordeling)');
        ExpectedTaxCodes.Add('K300', 'Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - forholdsmæssig andel)');
        ExpectedTaxCodes.Add('K310', 'Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K320', 'Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K330', 'Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt samt Købsmoms (indgående moms 33,3%)');
        ExpectedTaxCodes.Add('K340', 'Skal ikke medtages i angivelsen');
        ExpectedTaxCodes.Add('K410', 'Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K420', 'Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - skønsmæssig andel)');
        ExpectedTaxCodes.Add('K430', 'Moms af varekøb i udlandet (både EU og lande uden for EU)');
        ExpectedTaxCodes.Add('K440', 'Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - omsætningsfordeling)');
        ExpectedTaxCodes.Add('K450', 'Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - forholdsmæssig andel)');
        ExpectedTaxCodes.Add('K460', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)');
        ExpectedTaxCodes.Add('K470', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - skønsmæssig andel)');
        ExpectedTaxCodes.Add('K480', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt');
        ExpectedTaxCodes.Add('K490', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - omsætningsfordeling)');
        ExpectedTaxCodes.Add('K500', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - forholdsmæssig andel)');

        // [WHEN] LoadStandardTaxCodes is called
        Result := CreateStandardDataSAFTDK.LoadStandardTaxCodes();

        // [THEN] The method returns true
        Assert.IsTrue(Result, 'LoadStandardTaxCodes should return true.');

        // [THEN] VAT Reporting Codes are loaded correctly
        foreach TaxCode in ExpectedTaxCodes.Keys do begin
            VATReportingCode.Get(TaxCode);
            Assert.AreEqual(ExpectedTaxCodes.Get(TaxCode), VATReportingCode.Description, 'Tax code ' + TaxCode + ' description is incorrect.');
        end;
    end;

    [Test]
    [HandlerFunctions('SendNotificationHandler')]
    procedure NotificationShownForFourDigitStandardAccount()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        MyNotifications: Record "My Notifications";
        AuditFileExportDocuments: TestPage "Audit File Export Documents";
    begin
        // [FEATURE] [AI test]
        // [FEATURE] [RegF][DK] New Standard Chart of Accounts 2025
        // [SCENARIO] Notification is shown when Audit File Export Setup has "Four Digit Standard Account"

        // [GIVEN] Audit File Export Setup with Standard Account Type "Four Digit Standard Account", notification not disabled
        AuditFileExportSetup.DeleteAll();
        AuditFileExportSetup.Init();
        AuditFileExportSetup."Standard Account Type" := AuditFileExportSetup."Standard Account Type"::"Four Digit Standard Account";
        AuditFileExportSetup.Insert();

        MyNotifications.SetRange("Notification Id", GetStandardAccount2025NotificationId());
        MyNotifications.DeleteAll();

        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(StandardAccount2025AvailableMsg);

        // [WHEN] User opens "Audit File Export Documents" page
        AuditFileExportDocuments.OpenView();

        // [THEN] Notification with message 'New standard account type is available for year 2025.' is sent
        // Verified in SendNotificationHandler
        AuditFileExportDocuments.Close();
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure NotificationNotShownWhenSetupNotExists()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        AuditFileExportDocuments: TestPage "Audit File Export Documents";
    begin
        // [FEATURE] [AI test]
        // [FEATURE] [RegF][DK] New Standard Chart of Accounts 2025
        // [SCENARIO] Notification is not shown when Audit File Export Setup does not exist

        // [GIVEN] No Audit File Export Setup record exists
        AuditFileExportSetup.DeleteAll();

        // [WHEN] User opens "Audit File Export Documents" page
        AuditFileExportDocuments.OpenView();

        // [THEN] No notification is sent (page opens without error)
        AuditFileExportDocuments.Close();
    end;

    [Test]
    procedure NotificationNotShownWhenStandardAccount2025Configured()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        AuditFileExportDocuments: TestPage "Audit File Export Documents";
    begin
        // [FEATURE] [AI test]
        // [FEATURE] [RegF][DK] New Standard Chart of Accounts 2025
        // [SCENARIO] Notification is not shown when Audit File Export Setup already has "Standard Account 2025"

        // [GIVEN] Audit File Export Setup with Standard Account Type "Standard Account 2025"
        AuditFileExportSetup.DeleteAll();
        AuditFileExportSetup.Init();
        AuditFileExportSetup."Standard Account Type" := AuditFileExportSetup."Standard Account Type"::"Standard Account 2025";
        AuditFileExportSetup.Insert();

        // [WHEN] User opens "Audit File Export Documents" page
        AuditFileExportDocuments.OpenView();

        // [THEN] No notification is sent
        AuditFileExportDocuments.Close();
    end;

    [Test]
    procedure NotificationNotShownWhenUserDisabledNotification()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        MyNotifications: Record "My Notifications";
        AuditFileExportDocuments: TestPage "Audit File Export Documents";
    begin
        // [FEATURE] [AI test]
        // [FEATURE] [RegF][DK] New Standard Chart of Accounts 2025
        // [SCENARIO] Notification is not shown when user has disabled the notification

        // [GIVEN] Audit File Export Setup with Standard Account Type "Four Digit Standard Account"
        AuditFileExportSetup.DeleteAll();
        AuditFileExportSetup.Init();
        AuditFileExportSetup."Standard Account Type" := AuditFileExportSetup."Standard Account Type"::"Four Digit Standard Account";
        AuditFileExportSetup.Insert();

        // [GIVEN] My Notifications record for current user with notification ID disabled
        MyNotifications.SetRange("Notification Id", GetStandardAccount2025NotificationId());
        MyNotifications.DeleteAll();
        MyNotifications.Init();
        MyNotifications."User Id" := CopyStr(UserId(), 1, MaxStrLen(MyNotifications."User Id"));
        MyNotifications."Notification Id" := GetStandardAccount2025NotificationId();
        MyNotifications.Enabled := false;
        MyNotifications.Insert();

        // [WHEN] User opens "Audit File Export Documents" page
        AuditFileExportDocuments.OpenView();

        // [THEN] No notification is sent
        AuditFileExportDocuments.Close();
    end;

    [SendNotificationHandler]
    procedure SendNotificationHandler(var Notification: Notification): Boolean
    var
        Assert: Codeunit Assert;
        ExpectedMessage: Text;
    begin
        ExpectedMessage := LibraryVariableStorage.DequeueText();
        Assert.AreEqual(ExpectedMessage, Notification.Message(), 'Notification message is incorrect.');
        exit(true);
    end;

    local procedure GetStandardAccount2025NotificationId(): Guid
    begin
        exit('a1b0c3e4-d5f6-4a7b-8c9d-0e1f2a3b4c5d');
    end;

    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        StandardAccount2025AvailableMsg: Label 'New standard account type is available for year 2025.';
}