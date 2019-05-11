declare const AppsFlyerIntegration:
    | {disabled: true}
    | (() => Promise<void>)

export = AppsFlyerIntegration

interface IAppsFlyerDeviceIdWrapper {
    appsFlyerId: string
}
export interface IAppsFlyerSDKOptions {
    devKey: string
    isDebug: boolean
    appId?: string
}
export interface IAppsFlyerEventProps {
    context: {
        device: {
            type: string
            advertisingId: string
        }
    }
    integrations: {
        AppsFlyer: IAppsFlyerDeviceIdWrapper | boolean
    }
}
export interface IAppsFlyerEmailOptions {
    emails: string[]
    emailsCryptType: 0 | 1 | 2 // NONE - 0 (default), SHA1 - 1, MD5 - 2
}
export type AppsFlyerInstallConversionDisposer = () => void