interface "Contoso Demo Data Module"
{
    procedure RunConfigurationPage();
    procedure GetDependencies() Dependencies: List of [Enum "Contoso Demo Data Module"];
    procedure CreateSetupData();
    procedure CreateMasterData();
    procedure CreateTransactionalData();
    procedure CreateHistoricalData();
}