const Dashcam = new Vue({
    el: "#Dashcam_Body",

    data: {
        showDash: false,
        clockTime: {},
        dashMessageOne: "Property of",
        dashLabel: "Phoenix Protocol",
        department: "PPRP",
        callsign: "CAM-1",
        unitSpeed: 0,
        useMPH: true,
        lightsOn: false,
        sirenOn: false
    },

    methods: {

        EnableDashcam() {
            this.showDash = true;
        },

        DisableDashcam() {
            this.showDash = false;
        },

        UpdateDashcam(data) {
            this.clockTime = data.clockTime;
            this.department = data.department;
            this.callsign = data.callsign;
            this.unitSpeed = data.unitSpeed;
            this.useMPH = data.useMPH;
            this.lightsOn = data.lightsOn;
            this.sirenOn = data.sirenOn;
        },

    }
});

document.onreadystatechange = () => {
    if (document.readyState === "complete") {
        window.addEventListener('message', function(event) {
            if (event.data.type == "enabledash") {
                
                Dashcam.EnableDashcam();

            } else if (event.data.type == "disabledash") {

                Dashcam.DisableDashcam();

            } else if (event.data.type == "updatedash") {

                Dashcam.UpdateDashcam(event.data.info);

            }

        });
    };
};