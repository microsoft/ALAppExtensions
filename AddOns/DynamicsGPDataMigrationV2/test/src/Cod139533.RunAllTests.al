codeunit 139533 "MigrationGP RunAllTests"
{
    trigger OnRun();

    var
        MigrationGPAccountTests: Codeunit "MigrationGP Account Tests";
        MigrationGPItemTests: Codeunit "MigrationGP Item Tests";
        GPDataMigrationTests: Codeunit "GP Data Migration Tests";
        GPTransactionTests: Codeunit "MigrationGP Transaction Tests";
        GPForecastingTests: Codeunit "GP Forecasting Tests";
    begin
        MigrationGPAccountTests.Run();
        GPDataMigrationTests.Run();
        GPTransactionTests.Run();
        MigrationGPItemTests.Run();
        GPForecastingTests.Run();
    end;
}