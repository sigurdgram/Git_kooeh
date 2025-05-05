extends GutTest

const assetType = "TestAsset"
const assetCharA = "TestAsset.A"
const assetCharB = "TestAsset.B"



func after_each():
    AssetManager.unload_all_assets()
    pass

func test_load_single_asset():
    AssetManager.load_asset(assetCharA)

    assert_true(AssetManager.get_num_loaded_assets() == 1, "loadedAssets size should be 1")

    var path = AssetManager.get_asset_path(assetCharA)
    assert_true(ResourceLoader.has_cached(path), "Asset should be cached")
    assert_no_new_orphans()
    pass

func test_load_multiple_assets_of_type():
    AssetManager.load_assets_of_type(assetType)

    assert_true(AssetManager.get_num_loaded_assets() == 2, "loadedAssets size should be 2")

    var assetIds = AssetManager.get_asset_ids_of_type(assetType)
    for i in assetIds:
        var path = AssetManager.get_asset_path(i)
        assert_true(ResourceLoader.has_cached(path), "%s is cached" % path)

    assert_no_new_orphans()
    pass

func test_load_multiple_asset_ids():
    var ids: Array[String] = [assetCharA, assetCharB]

    AssetManager.load_asset_of_ids(ids)
    assert_true(AssetManager.get_num_loaded_assets() == 2, "loadedAssets size should be 2")

    for i in ids:
        var path = AssetManager.get_asset_path(i)
        assert_true(ResourceLoader.has_cached(path), "%s is cached" % path)

    assert_no_new_orphans()
    pass

func test_unload_single_asset():
    test_load_single_asset()

    AssetManager.unload_asset(assetCharA)
    assert_true(AssetManager.get_num_loaded_assets() == 0, "loadedAssets size should be 0")
    var path = AssetManager.get_asset_path(assetCharA)
    assert_false(ResourceLoader.has_cached(path), "Asset should not be cached")
    assert_no_new_orphans()
    pass

func test_unload_multiple_assets_of_type():
    test_load_multiple_assets_of_type()

    AssetManager.unload_assets_of_type(assetType)
    assert_true(AssetManager.get_num_loaded_assets() == 0, "loadedAssets size should be 0")

    var assetIds = AssetManager.get_asset_ids_of_type(assetType)
    for i in assetIds:
        var path = AssetManager.get_asset_path(i)
        assert_false(ResourceLoader.has_cached(path), "%s not cached" % path)

    assert_no_new_orphans()
    pass

func test_unload_multiple_assets_of_ids():
    test_load_multiple_asset_ids()

    var ids: Array[String] = [assetCharA, assetCharB]
    AssetManager.unload_assets(ids)

    assert_true(AssetManager.get_num_loaded_assets() == 0, "loadedAssets size should be 0")

    for i in ids:
        var path = AssetManager.get_asset_path(i)
        assert_false(ResourceLoader.has_cached(path), "%s not cached" % path)

    assert_no_new_orphans()
    pass
