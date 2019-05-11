import { Platform, NativeModules, NativeEventEmitter } from 'react-native'
var disabled =
  Platform.OS === 'ios'
    ? 'false' === 'true'
    : Platform.OS === 'android'
      ? 'false' === 'true'
      : true

if (disabled) {
  module.exports = { disabled: true }
} else {
  const bridge = NativeModules['RNAnalyticsIntegration_AppsFlyer']

  if (!bridge) {
    throw new Error('Failed to load AppsFlyer integration native module')
  }

  const emitter = new NativeEventEmitter(bridge)
  const eventsMap = {}

  // module.exports = bridge.setup
  class AppsFlyerBridge {
    constructor() {
      console.log('WTF constructor ????')
      this.disabled = false
    }

    appsFlyerId() {
      return bridge.appsFlyerId()
    }

    setup() {
      console.log('WTF setup')
      return bridge.setup()
    }

    /**
     * Accessing AppsFlyer Attribution / Conversion Data from the SDK(Deferred Deeplinking)
     * @param callback: contains fields:
     * status: success / failure
     * type:
     * onAppOpenAttribution
     * onInstallConversionDataLoaded
     * onAttributionFailure
     * onInstallConversionFailure
     * data: metadata,
     * @example { "status": "success", "type": "onInstallConversionDataLoaded", "data": { "af_status": "Organic", "af_message": "organic install" } }
     *
     * @returns { remove: function - unregister listener }
     */
    onInstallConversionData(callback) {
      console.log('WTF 1 ????')
      // console.log('onInstallConversionData is called')

      const subscription = emitter.addListener(
        'onInstallConversionData',
        _data => {
          console.log('WTF 2 ????')

          if (callback && typeof callback === typeof Function) {
            try {
              let data = JSON.parse(_data)
              callback(data)
            } catch (_error) {
              //throw new AFParseJSONException("...");
              //TODO: for today we return an error in callback
              // callback(new AFParseJSONException("Invalid data structure", _data));
              callback({
                data: _data,
                message: 'Invalid data structure',
                name: 'AFParseJSONException'
              })
            }
          }
        }
      )

      eventsMap['onInstallConversionData'] = subscription

      // unregister listener (suppose should be called from componentWillUnmount() )
      return function remove() {
        subscription.remove()
      }
    }
  }
  module.exports = new AppsFlyerBridge()
}
