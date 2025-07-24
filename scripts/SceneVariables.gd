extends Node

enum BudgetTier {
	LOW,
	MED,
	HIGH
}

var quarter_scores = {}
var full_cpu_scorer_statlines = {}
var full_player_scorer_statlines = {}
var player_score := 0
var cpu_score := 0
var player_team_bp_configs := {}
var player_strategy_card_deck := []
var budget_tier := BudgetTier.LOW

var all_player_names = [
"DerrickWhite", "CarisLevert", "DomantasSabonis", "DeAaronFox", "DeAnthonyMelton", "JamalMurray", "CameronPayne", "DeanWade", "KentaviousCaldwellPope", "DavionMitchell", "ShaiGilgeousAlexander", "ChrisPaul", "JalenMcDaniels", "AnthonyLamb", "JaeCrowder", "CediOsman", "JamesHarden", "IvicaZubac", "CamThomas", "JoshOkogie", "DariusGarland", "JohnKonchar", "AndrewWiggins", "KawhiLeonard", "MalcolmBrogdon", "JoeIngles", "MichaelPorterJr", "AlHorford", "KlayThompson", "BruceBrown", "GrantWilliams", "AaronGordon", "JoelEmbiid", "JalenBrunson", "JoeHarris", "JockLandale", "JaylenBrown", "JaMorant", "JordanPoole", "DevinBooker", "DraymondGreen", "ImmanuelQuickley", "JevonCarter", "KevonLooney", "BobbyPortis", "GiannisAntetokounmpo", "JeffGreen", "JarenJacksonJr", "BonesHyland", "LukeKennard", "JaysonTatum", "MarcusSmart", "DorianFinneySmith", "IsaacOkoro", "GeorgesNiang", "MalikMonk", "BrandonClarke", "JuliusRandle", "JrueHoliday", "CameronJohnson", "BrookLopez", "DamionLee", "HarrisonBarnes", "LamarStevens", "ChristianBraun", "DesmondBane", "KeeganMurray", "KevinHuerter", "DeAndreAyton", "BenSimmons", "DillonBrooks", "JonathanKuminga", "EvanMobley", "DonovanMitchell", "IsaiahHartenstein", "MasonPlumlee", "GraysonAllen", "MikalBridges", "ChimezieMetu", "JoshHart", "KevinDurant", "DonteDivincenzo", "JarettAllen"
]

var all_strategy_card_names = ["BlinkAndYoullMissHim", "HesHeatingUp", "Layup", "BoxingOut", "GoodPosition", "HalfCourtSet", "ChaseDownBlock", "AndOne", "DefensiveRebound", "KillerCrossover"]