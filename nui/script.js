const Dashcam = new Vue({
    el: "#Dashcam_Body",
    data: {
        showDash: false,
        dashMessageOne: "Property of",
        dashLabel: "Phoenix Protocol",
        department: "PPRP",
        callsign: "CAM-1",
        unitSpeed: 0,
        targetSpeed: 0,
        useMPH: true,
        lightsOn: false,
        sirenOn: false
    },
    computed: {
        displaySpeed() {
            this.unitSpeed += (this.targetSpeed - this.unitSpeed) * 0.2;
            return Math.floor(this.unitSpeed);
        },
        displayClock() {
            const now = new Date();
            const pad = n => String(n).padStart(2, "0");
            return `${pad(now.getMonth() + 1)}-${pad(now.getDate())}-${now.getFullYear()} - ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
        }
    },
    methods: {
        EnableDashcam() { this.showDash = true; },
        DisableDashcam() { this.showDash = false; },
        UpdateDashcam(data) {
            this.department = data.department;
            this.callsign = data.callsign;
            this.targetSpeed = data.unitSpeed;
            this.useMPH = data.useMPH;
            this.lightsOn = !!data.lightsOn;
            this.sirenOn = !!data.sirenOn;
        }
    }
});

document.onreadystatechange = () => {
    if (document.readyState === "complete") {
        window.addEventListener('message', function (event) {
            if (event.data.type === "enabledash") Dashcam.EnableDashcam();
            else if (event.data.type === "disabledash") Dashcam.DisableDashcam();
            else if (event.data.type === "updatedash") Dashcam.UpdateDashcam(event.data.info);
        });
    }
};
