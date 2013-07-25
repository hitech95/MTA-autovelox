resourceRoot = getResourceRootElement( getThisResource())
root = getRootElement()

function loadWarningSignTexture()
	signtext = engineLoadTXD("txd/speedsign.txd")
	engineImportTXD(signtext, 3380)
	
	boxtxt = engineLoadTXD("txd/box.txd")
	engineImportTXD(boxtxt, 1625)
	
	engineSetModelLODDistance(1625, 300)
	engineSetModelLODDistance(1886, 300)
	engineSetModelLODDistance(16101, 300)
end
addEventHandler("onClientResourceStart", getResourceRootElement(), loadWarningSignTexture)