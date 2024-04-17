capture erase lstdmest.mlib
quietly {
    do "./stdmest/stdmest.mata"
    do "./stdmestm/stdmestm.mata"

    mata: mata mlib create lstdmest, dir(.)
    mata: mata mlib add lstdmest *(), dir(.)
    mata: mata d *()
	mata mata clear
	mata mata mlib index
}
