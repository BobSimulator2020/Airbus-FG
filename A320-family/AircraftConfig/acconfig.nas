# Aircraft Config Center
# Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)

var spinning = maketimer(0.05, func {
	var spinning = getprop("/systems/acconfig/spinning");
	if (spinning == 0) {
		setprop("/systems/acconfig/spin", "\\");
		setprop("/systems/acconfig/spinning", 1);
	} else if (spinning == 1) {
		setprop("/systems/acconfig/spin", "|");
		setprop("/systems/acconfig/spinning", 2);
	} else if (spinning == 2) {
		setprop("/systems/acconfig/spin", "/");
		setprop("/systems/acconfig/spinning", 3);
	} else if (spinning == 3) {
		setprop("/systems/acconfig/spin", "-");
		setprop("/systems/acconfig/spinning", 0);
	}
});

var failReset = func {
	systems.ELEC.resetFail();
	systems.PNEU.resetFailures();
	fbw.FBW.resetFail();
	systems.HYD.resetFail();
}

var failResetOld = func {
	setprop("/systems/failures/aileron-left", 0);
	setprop("/systems/failures/aileron-right", 0);
	setprop("/systems/failures/elevator-left", 0);
	setprop("/systems/failures/elevator-right", 0);
	setprop("/systems/failures/fire/cargo-aft-fire", 0);
	setprop("/systems/failures/fire/cargo-fwd-fire", 0);
	setprop("/systems/failures/fire/engine-left-fire", 0);
	setprop("/systems/failures/fire/apu-fire", 0);
	setprop("/systems/failures/fire/engine-right-fire", 0);
	setprop("/systems/failures/fire/lavatory-fire", 0);
}

failResetOld();

setprop("/systems/acconfig/autoconfig-running", 0);
setprop("/systems/acconfig/spinning", 0);
setprop("/systems/acconfig/spin", "-");
setprop("/systems/acconfig/options/revision", 0);
setprop("/systems/acconfig/new-revision", 0);
setprop("/systems/acconfig/out-of-date", 0);
setprop("/systems/acconfig/mismatch-code", "0x000");
setprop("/systems/acconfig/mismatch-reason", "XX");
setprop("/systems/acconfig/options/keyboard-mode", 0);
setprop("/systems/acconfig/options/fgcamera-keys-enabled", 0);
setprop("/systems/acconfig/options/weight-kgs", 1);
setprop("/systems/acconfig/options/adirs-skip", 0);
setprop("/systems/acconfig/options/allow-oil-consumption", 0);
setprop("/systems/acconfig/options/atis-server", "faa");
setprop("/systems/acconfig/options/wxr-server", "noaa");
setprop("/systems/acconfig/options/welcome-skip", 0);
setprop("/systems/acconfig/options/no-rendering-warn", 0);
setprop("/systems/acconfig/options/save-state", 0);
setprop("/systems/acconfig/options/seperate-tiller-axis", 0);
setprop("/systems/acconfig/options/nd-rate", 1);
setprop("/systems/acconfig/options/autopush/show-route", 1);
setprop("/systems/acconfig/options/autopush/show-wingtip", 1);
var main_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/main/dialog", "Aircraft/A320-family/AircraftConfig/main.xml");
var welcome_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/welcome/dialog", "Aircraft/A320-family/AircraftConfig/welcome.xml");
var ps_load_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/psload/dialog", "Aircraft/A320-family/AircraftConfig/psload.xml");
var ps_loaded_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/psloaded/dialog", "Aircraft/A320-family/AircraftConfig/psloaded.xml");
var init_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/init/dialog", "Aircraft/A320-family/AircraftConfig/ac_init.xml");
var help_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/help/dialog", "Aircraft/A320-family/AircraftConfig/help.xml");
var fbw_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/fbw/dialog", "Aircraft/A320-family/AircraftConfig/fbw.xml");
var fail_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/fail/dialog", "Aircraft/A320-family/AircraftConfig/fail.xml");
var about_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/about/dialog", "Aircraft/A320-family/AircraftConfig/about.xml");
var update_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/update/dialog", "Aircraft/A320-family/AircraftConfig/update.xml");
var updated_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/updated/dialog", "Aircraft/A320-family/AircraftConfig/updated.xml");
var error_mismatch = gui.Dialog.new("/sim/gui/dialogs/acconfig/error/mismatch/dialog", "Aircraft/A320-family/AircraftConfig/error-mismatch.xml");
var fuel_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/fuel/dialog", "Aircraft/A320-family/AircraftConfig/fuel.xml");
var groundservices_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/groundsrvc/dialog", "Aircraft/A320-family/AircraftConfig/groundservices.xml");
var loadflightplan_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/loadfpln/dialog","Aircraft/A320-family/AircraftConfig/load-flightplan.xml");
var simbrief_dlg = gui.Dialog.new("/sim/gui/dialogs/acconfig/simbrief/dialog","Aircraft/A320-family/AircraftConfig/simbrief.xml");
var du_quality = gui.Dialog.new("/sim/gui/dialogs/acconfig/du-quality/dialog", "Aircraft/A320-family/AircraftConfig/du-quality.xml");
var rendering_dlg = gui.Dialog.new("/sim/gui/dialogs/rendering/dialog", "Aircraft/A320-family/AircraftConfig/rendering.xml");
spinning.start();
init_dlg.open();
var revisionFile = (getprop("sim/aircraft-dir") ~ "/revision.txt");
var current_revision = io.readfile(revisionFile);
print("A320-family Revision: " ~ current_revision);
setprop("/systems/acconfig/revision", current_revision);

var foViewNode = props.globals.initNode("/systems/acconfig/options/fo-view", 0, "BOOL");
setprop("/systems/acconfig/options/simbrief-username", "");

var fgfsMin = split(".", getprop("/sim/minimum-fg-version"));
var fgfsVer = split(".", getprop("/sim/version/flightgear"));

var versionCheck = func() {
	if (fgfsVer[0] < fgfsMin[0] or fgfsVer[1] < fgfsMin[1]) {
		return 0;
	} else if (fgfsVer[1] == fgfsMin[1]) {
		if (fgfsVer[2] < fgfsMin[2]) {
			return 0;
		} else {
			return 1;
		}
	} else {
		return 1;
	}
}

var mismatch_chk = func {
	if (!versionCheck()) {
		setprop("/systems/acconfig/mismatch-code", "0x121");
		setprop("/systems/acconfig/mismatch-reason", "FGFS version is too old! Please update FlightGear to at least " ~ getprop("/sim/minimum-fg-version") ~ ".");
		if (getprop("/systems/acconfig/out-of-date") != 1) {
			error_mismatch.open();
		}
		print("Mismatch: 0x121");
		welcome_dlg.close();
	} else if (getprop("/gear/gear[0]/wow") == 0 or getprop("/position/altitude-ft") >= 15000) {
		setprop("/systems/acconfig/mismatch-code", "0x223");
		setprop("/systems/acconfig/mismatch-reason", "Preposterous configuration detected for initialization. Check your position or scenery.");
		if (getprop("/systems/acconfig/out-of-date") != 1) {
			error_mismatch.open();
		}
		print("Mismatch: 0x223");
		welcome_dlg.close();
	} else if (getprop("/systems/acconfig/libraries-loaded") != 1) {
		setprop("/systems/acconfig/mismatch-code", "0x247");
		setprop("/systems/acconfig/mismatch-reason", "System files are missing or damaged. Please download a new copy of the aircraft.");
		if (getprop("/systems/acconfig/out-of-date") != 1) {
			error_mismatch.open();
		}
		print("Mismatch: 0x247");
		welcome_dlg.close();
	}
}

setlistener("/sim/signals/fdm-initialized", func {
	init_dlg.close();
	mismatch_chk();
	readSettings();
	if (getprop("/systems/acconfig/out-of-date") != 1 and getprop("/systems/acconfig/options/revision") < current_revision and getprop("/systems/acconfig/mismatch-code") == "0x000") {
		updated_dlg.open();
		if (getprop("/systems/acconfig/options/no-rendering-warn") != 1) {
			renderingSettings.check();
		}
	} else if (getprop("/systems/acconfig/out-of-date") != 1 and getprop("/systems/acconfig/mismatch-code") == "0x000" and getprop("/systems/acconfig/options/welcome-skip") != 1) {
		welcome_dlg.open();
		if (getprop("/systems/acconfig/options/no-rendering-warn") != 1) {
			renderingSettings.check();
		}
	}
	setprop("/systems/acconfig/options/revision", current_revision);
	writeSettings();
	if (getprop("/options/system/save-state") == 1)
	{
		save.restore(save.default, pts.Sim.fgHome.getValue() ~ "/Export/" ~ pts.Sim.aircraft.getValue() ~ "-save.xml");
	}
	
	if (getprop("/options/system/fo-view") == 1) {
		view.setViewByIndex(100);
	}
	
	spinning.stop();
});

setlistener("/sim/signals/exit", func {
	save.save(save.default, pts.Sim.fgHome.getValue() ~ "/Export/" ~ pts.Sim.aircraft.getValue() ~ "-save.xml");
});

var renderingSettings = {
	check: func() {
		var rembrandt = getprop("/sim/rendering/rembrandt/enabled");
		var ALS = getprop("/sim/rendering/shaders/skydome");

		var landmass = getprop("/sim/rendering/shaders/landmass") >= 4;
		var model = getprop("/sim/rendering/shaders/model") >= 2;
		if (!rembrandt and (!ALS or !landmass or !model)) {
			rendering_dlg.open();
		}
	},
	fixAll: func() {
		me.fixCore();
		var landmass = getprop("/sim/rendering/shaders/landmass") >= 4;
		var model = getprop("/sim/rendering/shaders/model") >= 2;
		if (!landmass) {
			setprop("/sim/rendering/shaders/landmass", 4);
		}
		if (!model) {
			setprop("/sim/rendering/shaders/model", 2);
		}
	},
	fixCore: func() {
		setprop("/sim/rendering/shaders/skydome", 1); # ALS on
		setprop("/sim/rendering/shaders/custom-settings", 1);
		gui.popupTip("/Rendering Settings updated!");
	},
};

var readSettings = func {
	io.read_properties(pts.Sim.fgHome.getValue() ~ "/Export/A320-family-config.xml", "/systems/acconfig/options");
	setprop("/options/system/keyboard-mode", getprop("/systems/acconfig/options/keyboard-mode"));
	if (getprop("/sim/fgcamera/enable")) setprop("/options/system/fgcamera-keys-enabled", getprop("/systems/acconfig/options/fgcamera-keys-enabled")); # read only when FGCamera enabled
	setprop("/options/system/weight-kgs", getprop("/systems/acconfig/options/weight-kgs"));
	setprop("/options/system/save-state", getprop("/systems/acconfig/options/save-state"));
	setprop("/controls/adirs/skip", getprop("/systems/acconfig/options/adirs-skip"));
	setprop("/systems/apu/oil/allow-oil-consumption", getprop("/systems/acconfig/options/allow-oil-consumption"));
	setprop("/sim/model/autopush/route/show", getprop("/systems/acconfig/options/autopush/show-route"));
	setprop("/sim/model/autopush/route/show-wingtip", getprop("/systems/acconfig/options/autopush/show-wingtip"));
	setprop("/options/system/fo-view", foViewNode.getValue());
	setprop("/FMGC/simbrief-username", getprop("/systems/acconfig/options/simbrief-username"));
	setprop("/systems/atsu/atis-server", getprop("/systems/acconfig/options/atis-server"));
	setprop("/systems/atsu/wxr-server", getprop("/systems/acconfig/options/wxr-server"));
}

var writeSettings = func {
	setprop("/systems/acconfig/options/keyboard-mode", getprop("/options/system/keyboard-mode"));
	setprop("/systems/acconfig/options/fgcamera-keys-enabled", getprop("/options/system/fgcamera-keys-enabled"));
	setprop("/systems/acconfig/options/weight-kgs", getprop("/options/system/weight-kgs"));
	setprop("/systems/acconfig/options/save-state", getprop("/options/system/save-state"));
	setprop("/systems/acconfig/options/adirs-skip", getprop("/controls/adirs/skip"));
	setprop("/systems/acconfig/options/allow-oil-consumption", getprop("/systems/apu/oil/allow-oil-consumption"));
	setprop("/systems/acconfig/options/autopush/show-route", getprop("/sim/model/autopush/route/show"));
	setprop("/systems/acconfig/options/autopush/show-wingtip", getprop("/sim/model/autopush/route/show-wingtip"));
	foViewNode.setValue(getprop("/options/system/fo-view"));
	setprop("/systems/acconfig/options/simbrief-username", getprop("/FMGC/simbrief-username"));
	setprop("/systems/acconfig/options/atis-server", getprop("/systems/atsu/atis-server"));
	setprop("/systems/acconfig/options/wxr-server", getprop("/systems/atsu/wxr-server"));
	io.write_properties(pts.Sim.fgHome.getValue() ~ "/Export/A320-family-config.xml", "/systems/acconfig/options");
}

################
# Panel States #
################

# Abort auto-config and close dialog
var abortPanelStates = func {
	if (getprop("/systems/acconfig/autoconfig-running") == 1) {
		setprop("/systems/acconfig/autoconfig-running", 0);
	}
	ps_load_dlg.close();
	spinning.stop();
}

# Cold and Dark
var colddark = func {
	if (getprop("/systems/acconfig/mismatch-code") == "0x000") {
		spinning.start();
		ps_loaded_dlg.close();
		ps_load_dlg.open();
		setprop("/systems/acconfig/autoconfig-running", 1);
		setprop("/controls/gear/brake-left", 1);
		setprop("/controls/gear/brake-right", 1);
		# Initial shutdown, and reinitialization.
		setprop("/controls/engines/engine-start-switch", 1);
		setprop("/controls/engines/engine[0]/cutoff-switch", 1);
		setprop("/controls/engines/engine[1]/cutoff-switch", 1);
		setprop("/controls/flight/flaps", 0);
		pts.Controls.Flight.speedbrakeArm.setValue(0);
		setprop("/controls/flight/speedbrake", 0);
		setprop("/controls/gear/gear-down", 1);
		setprop("/controls/flight/elevator-trim", 0);
		setprop("/controls/switches/beacon", 0);
		setprop("/controls/switches/strobe", 0.0);
		setprop("/controls/switches/wing-lights", 0);
		setprop("/controls/lighting/nav-lights-switch", 0);
		setprop("/controls/lighting/turnoff-light-switch", 0);
		setprop("/controls/lighting/taxi-light-switch", 0.0);
		setprop("/controls/switches/landing-lights-l", 0.0);
		setprop("/controls/switches/landing-lights-r", 0.0);
		setprop("/controls/atc/mode-knob", 0);
		setprop("/controls/lighting/fcu-panel-knb", 0);
		setprop("/controls/lighting/main-panel-knb", 0);
		setprop("/controls/lighting/overhead-panel-knb", 0);
		atc.transponderPanel.modeSwitch(1);
		libraries.systemsInit();
		libraries.variousReset();
		failResetOld();
		if (getprop("/engines/engine[1]/n2-actual") < 2) {
			colddark_b();
		} else {
			var colddark_eng_off = setlistener("/engines/engine[1]/n2-actual", func {
				if (getprop("/engines/engine[1]/n2-actual") < 2) {
					removelistener(colddark_eng_off);
					colddark_b();
				}
			});
		}
	}
}
var colddark_b = func {
	# Continues the Cold and Dark script, after engines fully shutdown.
	setprop("/controls/apu/master", 0);
	settimer(func {
		setprop("/controls/gear/brake-left", 0);
		setprop("/controls/gear/brake-right", 0);
		setprop("/systems/acconfig/autoconfig-running", 0);
		ps_load_dlg.close();
		ps_loaded_dlg.open();
		spinning.stop();
	}, 2);
}

# Ready to Start Eng
var beforestart = func {
	if (getprop("/systems/acconfig/mismatch-code") == "0x000") {
		spinning.start();
		ps_loaded_dlg.close();
		ps_load_dlg.open();
		setprop("/systems/acconfig/autoconfig-running", 1);
		setprop("/controls/gear/brake-left", 1);
		setprop("/controls/gear/brake-right", 1);
		# First, we set everything to cold and dark.
		setprop("/controls/engines/engine-start-switch", 1);
		setprop("/controls/engines/engine[0]/cutoff-switch", 1);
		setprop("/controls/engines/engine[1]/cutoff-switch", 1);
		setprop("/controls/flight/flaps", 0);
		pts.Controls.Flight.speedbrakeArm.setValue(0);
		setprop("/controls/flight/speedbrake", 0);
		setprop("/controls/gear/gear-down", 1);
		setprop("/controls/flight/elevator-trim", 0);
		libraries.systemsInit();
		libraries.variousReset();
		setprop("/controls/oxygen/cockpit-oxygen-supply-pb", 1);
		failResetOld();
		
		# Now the Startup!
		props.globals.getNode("/controls/electrical/switches/bat-1").setValue(1);
		props.globals.getNode("/controls/electrical/switches/bat-2").setValue(1);
		setprop("/controls/apu/master", 1);
		settimer(func() {
			systems.APUController.APU.powerOn(); # guarantee it always works
			systems.APUController.APU.startCommand(1);
		}, 0.1);
		var apu_rpm_chk = setlistener("/engines/engine[2]/n1", func {
			if (getprop("/engines/engine[2]/n1") >= 98) {
				removelistener(apu_rpm_chk);
				beforestart_b();
			}
		});
	}
}
var beforestart_b = func {
	if (getprop("/systems/acconfig/autoconfig-running") == 0) {
		colddark();
		return 0; # auto-config aborted
	}
	# Continue with engine start prep.
	systems.FUEL.Switches.pumpLeft1.setValue(1);
	systems.FUEL.Switches.pumpLeft2.setValue(1);
	systems.FUEL.Switches.pumpCenter1.setValue(1);
	systems.FUEL.Switches.pumpCenter2.setValue(1);
	systems.FUEL.Switches.pumpRight1.setValue(1);
	systems.FUEL.Switches.pumpRight2.setValue(1);
	setprop("/controls/lighting/fcu-panel-knb", 1);
	setprop("/controls/lighting/main-panel-knb", 1);
	setprop("/controls/lighting/overhead-panel-knb", 1);
	setprop("/controls/electrical/switches/apu", 1);
	setprop("/controls/electrical/switches/galley", 1);
	setprop("/controls/electrical/switches/gen-1", 1);
	setprop("/controls/electrical/switches/gen-2", 1);
	setprop("/controls/pneumatics/switches/apu", 1);
	setprop("/controls/pneumatics/switches/bleed-1", 1);
	setprop("/controls/pneumatics/switches/bleed-2", 1);
	setprop("/controls/pneumatics/switches/pack-1", 1);
	setprop("/controls/pneumatics/switches/pack-2", 1);
	setprop("/controls/adirs/ir[0]/knob","1");
	setprop("/controls/adirs/ir[1]/knob","1");
	setprop("/controls/adirs/ir[2]/knob","1");
	if (systems.ADIRS.Switches.adrSw[0].getValue() != 1) { systems.ADIRSControlPanel.adrSw(0); }
	if (systems.ADIRS.Switches.adrSw[1].getValue() != 1) { systems.ADIRSControlPanel.adrSw(1); }
	if (systems.ADIRS.Switches.adrSw[2].getValue() != 1) { systems.ADIRSControlPanel.adrSw(2); }
	systems.ADIRSControlPanel.irModeSw(0, 1);
	systems.ADIRSControlPanel.irModeSw(1, 1);
	systems.ADIRSControlPanel.irModeSw(2, 1);
	systems.ADIRS.ADIRunits[0].instAlign();
	systems.ADIRS.ADIRunits[1].instAlign();
	systems.ADIRS.ADIRunits[2].instAlign();
	setprop("/controls/adirs/mcducbtn", 1);
	setprop("/controls/switches/beacon", 1);
	setprop("/controls/lighting/nav-lights-switch", 1);
	pts.Controls.Switches.noSmokingSwitch.setValue(0.5);
	pts.Controls.Switches.seatbeltSwitch.setValue(1.0);
	pts.Controls.Switches.emerLtsSwitch.setValue(0.5);
	setprop("/controls/radio/rmp[0]/on", 1);
	setprop("/controls/radio/rmp[1]/on", 1);
	setprop("/controls/radio/rmp[2]/on", 1);
	setprop("/systems/fadec/power-avail", 1);
	setprop("/systems/fadec/powered-time", -310);
	settimer(func {
		setprop("/controls/gear/brake-left", 0);
		setprop("/controls/gear/brake-right", 0);
		setprop("/systems/acconfig/autoconfig-running", 0);
		ps_load_dlg.close();
		ps_loaded_dlg.open();
		spinning.stop();
	}, 2);
}

# Ready to Taxi
var taxi = func {
	if (getprop("/systems/acconfig/mismatch-code") == "0x000") {
		spinning.start();
		ps_loaded_dlg.close();
		ps_load_dlg.open();
		setprop("/systems/acconfig/autoconfig-running", 1);
		setprop("/controls/gear/brake-left", 1);
		setprop("/controls/gear/brake-right", 1);
		# First, we set everything to cold and dark.
		setprop("/controls/engines/engine-start-switch", 1);
		setprop("/controls/engines/engine[0]/cutoff-switch", 1);
		setprop("/controls/engines/engine[1]/cutoff-switch", 1);
		setprop("/controls/flight/flaps", 0);
		pts.Controls.Flight.speedbrakeArm.setValue(0);
		setprop("/controls/flight/speedbrake", 0);
		setprop("/controls/gear/gear-down", 1);
		setprop("/controls/flight/elevator-trim", 0);
		libraries.systemsInit();
		libraries.variousReset();
		setprop("/controls/oxygen/cockpit-oxygen-supply-pb", 1);
		failResetOld();
		
		# Now the Startup!
		props.globals.getNode("/controls/electrical/switches/bat-1").setValue(1);
		props.globals.getNode("/controls/electrical/switches/bat-2").setValue(1);
		setprop("/controls/apu/master", 1);
		settimer(func() {
			systems.APUController.APU.powerOn(); # guarantee it always works
			systems.APUController.APU.startCommand(1);
		}, 0.1);
		var apu_rpm_chk = setlistener("/engines/engine[2]/n1", func {
			if (getprop("/engines/engine[2]/n1") >= 98) {
				removelistener(apu_rpm_chk);
				taxi_b();
			}
		});
	}
}
var taxi_b = func {
	if (getprop("/systems/acconfig/autoconfig-running") == 0) {
		colddark();
		return 0; # auto-config aborted
	}
	# Continue with engine start prep, and start engines.
	systems.FUEL.Switches.pumpLeft1.setValue(1);
	systems.FUEL.Switches.pumpLeft2.setValue(1);
	systems.FUEL.Switches.pumpCenter1.setValue(1);
	systems.FUEL.Switches.pumpCenter2.setValue(1);
	systems.FUEL.Switches.pumpRight1.setValue(1);
	systems.FUEL.Switches.pumpRight2.setValue(1);
	setprop("/controls/lighting/fcu-panel-knb", 1);
	setprop("/controls/lighting/main-panel-knb", 1);
	setprop("/controls/lighting/overhead-panel-knb", 1);
	setprop("/controls/electrical/switches/apu", 1);
	setprop("/controls/electrical/switches/galley", 1);
	setprop("/controls/electrical/switches/gen-1", 1);
	setprop("/controls/electrical/switches/gen-2", 1);
	setprop("/controls/pneumatics/switches/apu", 1);
	setprop("/controls/pneumatics/switches/bleed-1", 1);
	setprop("/controls/pneumatics/switches/bleed-2", 1);
	setprop("/controls/pneumatics/switches/pack-1", 1);
	setprop("/controls/pneumatics/switches/pack-2", 1);
	setprop("/controls/adirs/ir[0]/knob","1");
	setprop("/controls/adirs/ir[1]/knob","1");
	setprop("/controls/adirs/ir[2]/knob","1");
	if (systems.ADIRS.Switches.adrSw[0].getValue() != 1) { systems.ADIRSControlPanel.adrSw(0); }
	if (systems.ADIRS.Switches.adrSw[1].getValue() != 1) { systems.ADIRSControlPanel.adrSw(1); }
	if (systems.ADIRS.Switches.adrSw[2].getValue() != 1) { systems.ADIRSControlPanel.adrSw(2); }
	systems.ADIRSControlPanel.irModeSw(0, 1);
	systems.ADIRSControlPanel.irModeSw(1, 1);
	systems.ADIRSControlPanel.irModeSw(2, 1);
	systems.ADIRS.ADIRunits[0].instAlign();
	systems.ADIRS.ADIRunits[1].instAlign();
	systems.ADIRS.ADIRunits[2].instAlign();
	setprop("/controls/adirs/mcducbtn", 1);
	setprop("/controls/switches/beacon", 1);
	setprop("/controls/switches/wing-lights", 1);
	setprop("/controls/lighting/nav-lights-switch", 1);
	pts.Controls.Switches.noSmokingSwitch.setValue(0.5);
	pts.Controls.Switches.seatbeltSwitch.setValue(1.0);
	pts.Controls.Switches.emerLtsSwitch.setValue(0.5);
	setprop("/controls/radio/rmp[0]/on", 1);
	setprop("/controls/radio/rmp[1]/on", 1);
	setprop("/controls/radio/rmp[2]/on", 1);
	setprop("/controls/atc/mode-knob", 2);
	atc.transponderPanel.modeSwitch(3);
	setprop("/systems/fadec/power-avail", 1);
	setprop("/systems/fadec/powered-time", -310);
	setprop("/controls/lighting/turnoff-light-switch", 1);
	setprop("/controls/lighting/taxi-light-switch", 0.5);
	setprop("/controls/switches/landing-lights-l", 0.5);
	setprop("/controls/switches/landing-lights-r", 0.5);
	if (pts.Instrumentation.Altimeter.std.getBoolValue()) {
		libraries.toggleSTD();
	}
	setprop("/instrumentation/altimeter[0]/setting-inhg", getprop("/environment/metar[0]/pressure-inhg") or 29.92);
	setprop("/instrumentation/altimeter[6]/setting-inhg", getprop("/environment/metar[0]/pressure-inhg") or 29.92);
	settimer(taxi_c, 2);
}
var taxi_c = func {
	if (getprop("/systems/acconfig/autoconfig-running") == 0) {
		colddark();
		return 0; # auto-config aborted
	}
	setprop("/controls/engines/engine-start-switch", 2);
	setprop("/controls/engines/engine[0]/cutoff-switch", 0);
	setprop("/controls/engines/engine[1]/cutoff-switch", 0);
	settimer(func {
		taxi_d();
	}, 10);
}
var taxi_d = func {
	if (getprop("/systems/acconfig/autoconfig-running") == 0) {
		colddark();
		return 0; # auto-config aborted
	}
	# After Start items.
	setprop("/controls/engines/engine-start-switch", 1);
	setprop("/controls/apu/master", 0);
	setprop("/controls/pneumatics/switches/apu", 0);
	setprop("/controls/gear/brake-left", 0);
	setprop("/controls/gear/brake-right", 0);
	setprop("/systems/acconfig/autoconfig-running", 0);
	ps_load_dlg.close();
	ps_loaded_dlg.open();
	spinning.stop();
}

# Ready to Takeoff
var takeoff = func {
	if (getprop("/systems/acconfig/mismatch-code") == "0x000") {
		# The same as taxi, except we set some things afterwards.
		taxi();
		var eng_one_chk_c = setlistener("/engines/engine[0]/state", func {
			if (pts.Engines.Engine.state[0].getValue() == 3) {
				removelistener(eng_one_chk_c);
				setprop("/controls/switches/strobe", 1.0);
				setprop("/controls/lighting/taxi-light-switch", 1);
				setprop("/controls/switches/landing-lights-l", 1);
				setprop("/controls/switches/landing-lights-r", 1);
				pts.Controls.Flight.speedbrakeArm.setValue(1);
				setprop("/controls/flight/flaps", 0.2);
				setprop("/controls/atc/mode-knob", 4);
				atc.transponderPanel.modeSwitch(5);
				setprop("/controls/flight/elevator-trim", -0.07);
				systems.Autobrake.arm_autobrake(3);
				setprop("/ECAM/to-config-test", 1);
				settimer(func {
					setprop("/ECAM/to-config-test", 0);
				}, 1);
			}
		});
	}
}
