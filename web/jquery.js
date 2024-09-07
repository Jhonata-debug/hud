/* const nitroBar = new ldBar("#nitro"); */
var Voip = "Normal";
var Interval = undefined;
let valorAtu = 0
let valorBarraBranca = 1
let valorBarraVermelha = 1
let marcha1 = 0
let marcha2 = 0
let inDelay = false
// -------------------------------------------------------------------------------------------
function Minimal(Seconds){
	var Days = Math.floor(Seconds / 86400)
	Seconds = Seconds - Days * 86400
	var Hours = Math.floor(Seconds / 3600)
	Seconds = Seconds - Hours * 3600
	var Minutes = Math.floor(Seconds / 60)
	Seconds = Seconds - Minutes * 60

	const [D,H,M,S] = [Days,Hours,Minutes,Seconds].map(s => s.toString().padStart(2,0))

    if (Days > 0){
        return D + ":" + H
    } else if (Hours > 0){
        return H + ":" + M
    } else if (Minutes > 0){
        return M + ":" + S
    } else if (Seconds > 0){
        return "00:" + S
    }
}
// -------------------------------------------------------------------------------------------
const FormatNumber = n => {
	var n = n.toString();
	var r = "";
	var x = 0;

	for (var i = n["length"]; i > 0; i--) {
		r += n.substr(i - 1, 1) + (x == 2 && i != 1 ? "." : "");
		x = x == 2 ? 0 : x + 1;
	}

	return r.split("").reverse().join("");
}
// -------------------------------------------------------------------------------------------
window.addEventListener("message",function(event){
	switch (event["data"]["Action"]){
		case "Progress":
			const progressContainer = document.getElementById("progress-container");
            const progressCircle = document.getElementById("progress-circle");

            const time = event["data"]["Timer"];

            progressContainer.animate([{ opacity: 0 }, { opacity: 1 }], {
                easing: "ease-in-out",
                duration: 500,
                fill: "both",
            });

            progressCircle.animate([{ strokeDashoffset: 160 }, { strokeDashoffset: 0 }], {
                easing: "ease-in-out",
                duration: time,
                fill: "both",
            }).onfinish = () => {
                progressContainer.animate([{ opacity: 1 }, { opacity: 0 }], {
                    easing: "ease-in-out",
                    duration: 500,
                    fill: "both",
                });
            };
		break;

		case "Frequency":
			if(event["data"]["Frequency"] !== "Offline"){
				$("#radio_div").fadeIn(200)
				$(".Radio").html(event["data"]["Frequency"]);
			}else {
				$("#radio_div").fadeOut(200)
			};
		break;

		case "Body":
			if (event["data"]["Status"]){
				if ($("#Body").css("display") === "none"){
					$("#Body").fadeIn(1000);
				}
			} else {
				if ($("#Body").css("display") === "block"){
					$("#Body").fadeOut(1000);
				}
			}
		break;

		case "Gemstone":
			$(".Gemstone").html(FormatNumber(event["data"]["Number"]));
		break;

		case "Voip":
			if (event["data"]["Voip"] == "Offline"){
				$(".Voip").html("Offline");
			} else {
				if (event["data"]["Voip"] !== "Online"){
					Voip = event["data"]["Voip"];
				}

				$(".Voip").html(Voip);
			}
		break;

		case "Voice":
			$(".Voip").css("color",event["data"]["Status"]);
		break;

		case "Clock":
			var Hours = event["data"]["Hours"];
			var Minutes = event["data"]["Minutes"];

			if (Hours <= 9)
				Hours = "0" + Hours

			if (Minutes <= 9)
				Minutes = "0" + Minutes

			$(".Date").html(Hours + ":" + Minutes);
		break;

		case "Weather":
			$(".Weather").html(event["data"]["Weather"]);
		break;

		case "Temperature":
			$(".Temperature").html(event["data"]["Temperature"]);
		break;

		case "Wanted":
			if (event["data"]["Number"] > 0){
				if ($(".Wanted").css("display") === "none"){
					$(".Wanted").fadeIn(1000);
				}

				$(".WantedTimer").html(Minimal(event["data"]["Number"]));
			} else {
				if ($(".Wanted").css("display") === "block"){
					$(".Wanted").fadeOut(1000);
				}
			}
		break;

		case "Reposed":
			if (event["data"]["Number"] > 0){
				if ($(".Reposed").css("display") === "none"){
					$(".Reposed").fadeIn(1000);
				}

				$(".ReposedTimer").html(Minimal(event["data"]["Number"]));
			} else {
				if ($(".Reposed").css("display") === "block"){
					$(".Reposed").fadeOut(1000);
				}
			}
		break;

		case "Road":
			$("#infoStreet").fadeIn()
			$(".UpStreet").html(event["data"]["Name"]+" | ");
		break;

		case "Crossing":
			$("#infoStreet").fadeIn()
			$(".DownStreet").html(event["data"]["Name"]);
		break;

		case "Health":
			if (event["data"]["Number"] <= 100){
				$("#health").fadeIn(500)
				if(event["data"]["Number"] >= 100){
					$(".content-health").css("width",`100%`)
					$(".Vida").fadeOut(500);
				}else{
					$(".content-health").css("width",`${event["data"]["Number"]}%`)
					$(".Vida").fadeOut(500);
				}
				if(event["data"]["Status"]){
					if ($(".Health").css("display") === "none"){
						$(".Health").fadeIn(1000);
						$(".Health").css("stroke-dashoffset",100 - event["data"]["Number"]);
					}
				}else{
					$("#health").fadeIn(500)
					if(event["data"]["Number"] >= 100){
						$(".content-health").css("width",`100%`)
						$(".Vida").fadeOut(500);
					}else{
						$(".content-health").css("width",`${event["data"]["Number"]}%`)
						$(".Vida").fadeOut(500);
					}
				}
			} else {
				if ($(".Health").css("display") === "block"){
					$(".Vida").fadeOut(1000);
				}
			}
		break;

		case "Oxigen":
			if (event["data"]["Number"] < 81){
				if ($(".Oxigen").css("display") === "none"){
					$(".Oxigen").fadeIn(1000);
				}

				$(".Oxigen").css("stroke-dashoffset",100 - event["data"]["Number"]);
			} else {
				if ($(".Oxigen").css("display") === "block"){
					$(".Oxigen").fadeOut(1000);
				}
			}
		break;

		case "Armour":
			if (event["data"]["Number"] > 0){
				if(event["data"]["Vehicle"]){
					if ($(".Armour").css("display") === "none"){ // REDONDO
						$(".Armour").fadeIn(1000);
						$(".Armour").css("stroke-dashoffset",100 - event["data"]["Number"]);
					}
				}else{
					if(event["data"]["Status"]){
						$(".Armour").fadeOut(1000);// REDONDO
					}else{
						if (event["data"]["Number"] > 0){
							$(".content-bars").fadeIn(200)
							$(".armor").fadeIn(500)
							if(event["data"]["Number"] >= 100){
								$(".content-armor").css("width",`100%`)
							}else{
								$(".armor").fadeIn();
								$(".content-armor").css("width",`${event["data"]["Number"]}%`)
							}
						}else{
							$(".armor").fadeOut(500)
							$(".Armour").fadeOut(500);
						}
						
					}
				}
			} else {
				$(".armor").fadeOut();
				$(".Armour").fadeOut();
			}
		break;

		case "Oxygen":
			if (event["data"]["Number"] < 100){
				if ($("#Oxygen").css("display") === "none"){
					$("#Oxygen").fadeIn(1000);
				}

				$(".Oxygen").css("stroke-dashoffset", 100 - event["data"]["Number"]);
			} else {
				if ($("#Oxygen").css("display") === "flex"){
					$("#Oxygen").fadeOut(1000);
				}
			}
		break;

		case "Hunger":
			if (event["data"]["Number"] < 101){
				if ($(".Hunger").css("display") === "none"){
					$(".Hunger").fadeIn(1000);
				}

				$(".Hunger").css("stroke-dashoffset",100 - event["data"]["Number"]);
			} else {
				if ($(".Hunger").css("display") === "block"){
					$(".Hunger").fadeOut(1000);
				}
			}
		break;

		case "Thirst":
			if (event["data"]["Number"] < 101){
				if ($(".Thirst").css("display") === "none"){
					$(".Thirst").fadeIn(1000);
				}

				$(".Thirst").css("stroke-dashoffset", 100 - event["data"]["Number"]);
			} else {
				if ($(".Thirst").css("display") === "block"){
					$(".Thirst").fadeOut(1000);
				}
			}
		break;

		case "Stress":
			if (event["data"]["Number"] < 101){
				if ($(".Stresss").css("display") === "none" && !event["data"]["Vehicle"]){
					$(".Stresss").fadeIn(1000);
				}

				$(".Stress").css("stroke-dashoffset",100 - event["data"]["Number"]);
			} else {
				if ($(".Stresss").css("display") === "block" && !event["data"]["Vehicle"]){
					$(".Stresss").fadeOut(1000);
				}
			}
		break;

		case "Cough":
			if (event["data"]["Number"] < 101){
				if ($(".Cough").css("display") === "none" && !event["data"]["Vehicle"]){
					$(".Cough").fadeIn(1000);
				}

				$(".Cough").css("stroke-dashoffset",100 - event["data"]["Number"]);
			} else {
				if ($(".Cough").css("display") === "block" && !event["data"]["Vehicle"]){
					$(".Cough").fadeOut(1000);
				}
			}
		break;

		case "Luck":
			if (event["data"]["Number"] > 0){
				if ($(".Lucks").css("display") === "none"){
					$(".Lucks").fadeIn(1000);
				}

				event["data"]["Number"] = event["data"]["Number"] / 36;

				$(".Luck").css("stroke-dashoffset",100 - event["data"]["Number"]);
			} else {
				if ($(".Lucks").css("display") === "block"){
					$(".Lucks").fadeOut(1000);
				}
			}
		break;

		case "Dexterity":
			if (event["data"]["Number"] > 0){
				if ($(".Dexteritys").css("display") === "none"){
					$(".Dexteritys").fadeIn(1000);
				}

				event["data"]["Number"] = event["data"]["Number"] / 36;

				$(".Dexterity").css("stroke-dashoffset",100 - event["data"]["Number"]);
			} else {
				if ($(".Dexteritys").css("display") === "block"){
					$(".Dexteritys").fadeOut(1000);
				}
			}
		break;

		case "Vehicle":
			if (event["data"]["Vehicle"]){ 
				$("#Tosse").fadeIn(100);
				$(".NaviBlock").addClass("vehicle")
				$("#cinto").removeClass("white_icon");

				$(".container_speedometer").fadeIn(600);

				if ($("#Streets").css("display") === "none"){
					$("#Streets").fadeIn(1000);
				}

				if ($("#StreetsIcon").css("display") === "none"){
					$("#StreetsIcon").fadeIn(1000);
				}

				if(event["data"]["Number"] > 0){
					$(".armor").fadeIn()
				}else{
					$(".armor").fadeOut()
				}
				$(".NaviBlock").fadeIn(200);
				$(".content-bars").fadeIn(200);
				//$(".armor").fadeIn(200);
				$("#health").fadeIn(200);
			} else {
				$(".NaviBlock").removeClass("vehicle")

				$(".container_speedometer").fadeOut(600);

				if ($("#Streets").css("display") === "flex"){
					$("#Streets").fadeOut(1000);
				}

				if ($("#StreetsIcon").css("display") === "flex"){
					$("#StreetsIcon").fadeOut(1000);
				}
				$("#infoStreet").fadeOut()

				$(".Vida").fadeOut()
				if(event["data"]["Number"] > 0){
					$(".armor").fadeIn()
					$(".Armour").fadeOut()
				}else{
					$("#armor").fadeOut()
					$(".Armour").fadeOut()
				}
				$(".NaviBlock").fadeIn(200);
				$(".content-bars").fadeIn(200);
				//$(".armor").fadeIn(200);
				$("#health").fadeIn(200);
			}
		break;

		case "Fuel":
			$("#progress_fuel").css("width",`${event["data"]["Number"]}%`);
		break;

		case "Speed":
			if(event["data"]["Number"] > 0 && event["data"]["Number"] <= 8){
				$("#veloci_speed").html(`00${parseInt(event["data"]["Number"])}`);
			}else if(event["data"]["Number"] > 9 && event["data"]["Number"] <= 98){
				$("#veloci_speed").html(`0${parseInt(event["data"]["Number"])}`);
			}else if(event["data"]["Number"] > 99){
				$("#veloci_speed").html(`${parseInt(event["data"]["Number"])}`);
			};
			let valor = event["data"]["Rpm"] ? event["data"]["Rpm"].toFixed(2) * 100 : 0
			marcha2 = event["data"]["Gear"]
			
			if(event["data"]["Number"] <= 0){
				valorBarraBranca = 1
				valorBarraVermelha = 1
				valorAtu = 0
				marcha = 0
				setTimeout(() => {
					$("#bar_red_5").removeClass("full_red");
					setTimeout(() => {
						$("#bar_red_4").removeClass("full_red");
						setTimeout(() => {
							$("#bar_red_3").removeClass("full_red");
							setTimeout(() => {
								$("#bar_red_2").removeClass("full_red");
								setTimeout(() => {
									$("#bar_red_1").removeClass("full_red");
									setTimeout(() => {
										$("#bar_14").removeClass("full_white");
										setTimeout(() => {
											$("#bar_13").removeClass("full_white");
											setTimeout(() => {
												$("#bar_12").removeClass("full_white");
												setTimeout(() => {
													$("#bar_11").removeClass("full_white");
													setTimeout(() => {
														$("#bar_10").removeClass("full_white");
														setTimeout(() => {
															$("#bar_9").removeClass("full_white");
															setTimeout(() => {
																$("#bar_8").removeClass("full_white");
																setTimeout(() => {
																	$("#bar_7").removeClass("full_white");
																	setTimeout(() => {
																		$("#bar_6").removeClass("full_white");
																		setTimeout(() => {
																			$("#bar_5").removeClass("full_white");
																			setTimeout(() => {
																				$("#bar_4").removeClass("full_white");
																				setTimeout(() => {
																					$("#bar_3").removeClass("full_white");
																					setTimeout(() => {
																						$("#bar_2").removeClass("full_white");
																						setTimeout(() => {
																							$("#bar_1").removeClass("full_white");
																						}, 80);
																					}, 80);
																				}, 80);
																			}, 80);
																		}, 80);
																	}, 80);
																}, 80);
															}, 80);
														}, 80);
													}, 80);
												}, 80);
											}, 80);
										}, 80);
									}, 80);
								}, 80);
							}, 80);
						}, 80);
					}, 80);
				}, 80);
			};
				
			if(valor > (21 + valorAtu)){
				if(valorBarraBranca < 15){
					valorAtu = valorAtu + 1
					$(`#bar_${valorBarraBranca}`).addClass("full_white");
					valorBarraBranca = valorBarraBranca + 1
				}else{
					if(valor >= (16 + valorAtu)){
						valorAtu = valorAtu + 1
						$(`#bar_red_${valorBarraVermelha}`).addClass("full_red");
						valorBarraVermelha = valorBarraVermelha + 1
						if(valorBarraVermelha > 5 && marcha1 !== marcha2){
							valorBarraBranca = 1
							valorBarraVermelha = 1
							valorAtu = 0
							$("#bar_1").removeClass("full_white");
							$("#bar_2").removeClass("full_white");
							$("#bar_3").removeClass("full_white");
							$("#bar_4").removeClass("full_white");
							$("#bar_5").removeClass("full_white");
							$("#bar_6").removeClass("full_white");
							$("#bar_7").removeClass("full_white");
							$("#bar_8").removeClass("full_white");
							$("#bar_9").removeClass("full_white");
							$("#bar_10").removeClass("full_white");
							$("#bar_11").removeClass("full_white");
							$("#bar_12").removeClass("full_white");
							$("#bar_13").removeClass("full_white");
							$("#bar_14").removeClass("full_white");
	
							$("#bar_red_1").removeClass("full_red");
							$("#bar_red_2").removeClass("full_red");
							$("#bar_red_3").removeClass("full_red");
							$("#bar_red_4").removeClass("full_red");
							$("#bar_red_5").removeClass("full_red");
						};
					};
				};
			};
		break;

		case "Gear":
			setTimeout(() => {
				marcha1 = event["data"]["Gear"]
				$("#marcha").html(`${event["data"]["Gear"]}`);
			}, 500);
		break;

		case "Handbrake":
			if (!event["data"]["Status"]){
				$(".Handbrake").addClass("Gray").removeClass("Red");
			} else {
				$(".Handbrake").addClass("Red").removeClass("Gray");
			}
		break;

		case "Seatbelt":
			if (!event["data"]["Status"]){
				$("#cinto").removeClass("white_icon");
			} else {
				$("#cinto").addClass("white_icon");
			}
		break;

		case "SetaEsquerda":
			if (!event["data"]["Status"]){
				$("#lightLeft").addClass("setaEsquerda");
				$("#lightRight").removeClass("setaDireita");
			} else {
				$("#lightLeft").removeClass("setaEsquerda");
			}
		break;

		case "SetaDireita":
			if (!event["data"]["Status"]){
				$("#lightRight").addClass("setaDireita");
				$("#lightLeft").removeClass("setaEsquerda");
			} else {
				$("#lightRight").removeClass("setaDireita");
			}
		break;

		case "Engine":
			$("#progress_engine").css("width",`${event["data"]["Number"]}%`);
		break;

		case "Drift":
			if (!event["data"]["Status"]){
				$(".Drift").addClass("Gray").removeClass("Hensa");
			} else {
				$(".Drift").addClass("Hensa").removeClass("Gray");
			}
		break;

		case "Headlight":
			if (event["data"]["Status"]){
				$("#farol").addClass("white_icon");
			}else {
				$("#farol").removeClass("white_icon");
			}
		break;

		case "Locked":
			if (event["data"]["Status"] == 2){
				$("#close").css("display","block")
				$("#open").addClass("white_icon").removeClass("trans_icon")

				$("#open").css("display","none");
			} else {
				$("#close").css("display","none");
				$("#close").removeClass("white_icon")
				$("#open").css("display","block");
				$("#open").addClass("trans_icon").removeClass("white_icon")
			}
		break;

		case "Tyres":
			if (event["data"]["Number"] == 0){
				$(".Tyres").addClass("Gray").removeClass("Hensa").removeClass("Red");
			} else if (event["data"]["Number"] == 1){
				$(".Tyres").addClass("Hensa").removeClass("Gray").removeClass("Red");
			} else if (event["data"]["Number"] >= 2){
				$(".Tyres").addClass("Red").removeClass("Gray").removeClass("Hensa");
			}
		break;

		case "Nitro":
			event["data"]["Number"] * 100 / 2000
			document.getElementById("nitro").style = `--nitroSet: ${event["data"]["Number"] ? event["data"]["Number"] : 0}%;`
		break;

		case "Weapons":
			if (event["data"]["Status"]){
				if ($("#NaviWeapons").css("display") === "none"){
					$("#NaviWeapons").fadeIn(1000);
				}

				$(".NameWeapon").html(event["data"]["Name"]);
				$(".NameAmmos").html(event["data"]["Min"] + " / " + event["data"]["Max"]);
			} else {
				if ($("#NaviWeapons").css("display") === "block"){
					$("#NaviWeapons").fadeOut(1000);
				}
			}
		break;

		case "Textform":
			if (event["data"]["Mode"] === "Create"){
				var html = `<span id=Textform-${event["data"]["Number"]} class="Textform" style="left: 0; top: 0;"></span>`;
				$(html).fadeIn("normal").appendTo("#Textform");
			} else if (event["data"]["Mode"] === "Update"){
				$("#Textform-" + event["data"]["Number"]).css("left",event["data"]["x"] * 100 + "%").css("top",event["data"]["y"] * 100 + "%");
				$("#Textform-" + event["data"]["Number"]).html(event["data"]["Text"])
			} else if (event["data"]["Mode"] === "Remove"){
				$("#Textform-" + event["data"]["Number"]).fadeOut("normal",function(){ $(this).remove(); });
			}
		break;

		case "Bounds":
			if (event["data"]["Left"]) {
				$(".NaviBlock").css("left", event["data"]["Left"] + "%")
			} else {
				$(".NaviBlock").removeAttr("style")
			}
		break;
	}
});