codeunit 42000 "GP Vendor 1099 Mig. Install"
{
    Subtype = Install;

    var
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";

    trigger OnInstallAppPerDatabase()
    begin
        GPVendor1099MappingHelpers.CleanMappings();
        Install2022Mappings();
    end;

    local procedure Install2022Mappings()
    var
        TaxYear: Integer;
    begin
        TaxYear := 2022;
        GPVendor1099MappingHelpers.InsertSupportedTaxYear(TaxYear);

        // DIV
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 1, 'DIV-01-A');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 2, 'DIV-01-B');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 3, 'DIV-02-A');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 4, 'DIV-02-B');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 5, 'DIV-02-C');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 6, 'DIV-02-D');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 17, 'DIV-02-E');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 18, 'DIV-02-F');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 7, 'DIV-03');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 8, 'DIV-04');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 9, 'DIV-05');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 10, 'DIV-06');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 11, 'DIV-07');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 12, 'DIV-09');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 13, 'DIV-10');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 14, 'DIV-12');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 15, 'DIV-13');

        // INT
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 1, 'INT-01');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 2, 'INT-02');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 3, 'INT-03');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 4, 'INT-04');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 5, 'INT-05');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 6, 'INT-06');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 7, 'INT-08');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 8, 'INT-09');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 9, 'INT-10');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 10, 'INT-11');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 11, 'INT-12');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 12, 'INT-13');

        // MISC
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 1, 'MISC-01');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 2, 'MISC-02');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 3, 'MISC-03');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 4, 'MISC-04');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 5, 'MISC-05');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 6, 'MISC-06');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 7, 'MISC-08');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 8, 'MISC-09');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 9, 'MISC-10');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 15, 'MISC-11');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 10, 'MISC-12');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 11, 'MISC-14');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 12, 'MISC-15');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 13, 'MISC-16');

        // NEC
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 5, 1, 'NEC-01');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 5, 2, 'NEC-04');
    end;
}