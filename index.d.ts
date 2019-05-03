declare const AppsFlyerIntegration:
    | {disabled: true}
    | (() => Promise<void>)

export = AppsFlyerIntegration
