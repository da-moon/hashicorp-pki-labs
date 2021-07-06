{
    "signing": {
        "default": {
            "usages": [
                "signing",
                "key encipherment",
                "server auth",
                "client auth"
            ],
            "expiry": "${DEFAULT_TTL}s"
        },
        "profiles": {
            "default": {
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ],
                "expiry": "${CERT_TTL}s"
            }
        }
    }
}
