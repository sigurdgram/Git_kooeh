extends ConfigFile
class_name AssetConfig

signal onLoaded

func set_value_(section: String, key: String, value: Variant):
    super .set_value(section, key, value)
    save(AssetManager.assetConfigPath)
    self.load(AssetManager.assetConfigPath)
    onLoaded.emit()
    pass

func erase_section_key_(section: String, key: String):
    super .erase_section_key(section, key)
    save(AssetManager.assetConfigPath)
    self.load(AssetManager.assetConfigPath)
    onLoaded.emit()
    pass

func erase_section_(section: String):
    super .erase_section(section)
    save(AssetManager.assetConfigPath)
    self.load(AssetManager.assetConfigPath)
    onLoaded.emit()
    pass
