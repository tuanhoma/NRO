package nro.map.MajinBuu14H;

/*
 * @Author: Anwin
 */

import nro.player.Player;
import nro.services.Fun.ChangeMapService;
import java.util.ArrayList;
import java.util.List;
import nro.map.Zone;

public class MajinBuu14HService {

    private static MajinBuu14HService instance;

    public static MajinBuu14HService gI() {
        if (instance == null) {
            instance = new MajinBuu14HService();
        }
        return instance;
    }

    public List<MajinBuu14H> maBu2Hs;

    private MajinBuu14HService() {
        this.maBu2Hs = new ArrayList<>();
        for (int i = 0; i < MajinBuu14H.AVAILABLE; i++) {
            this.maBu2Hs.add(new MajinBuu14H(i));
        }
    }

    public void addMapMaBu2H(int id, Zone zone) {
        if (zone.map.mapId == 128) {
            for (int slot = 0; slot < 4; slot++) {
                zone.maBuHolds.add(new MaBuHold(slot, null));
            }
        }
        this.maBu2Hs.get(id).getZones().add(zone);
    }

    public void joinMaBu2H(Player player) {
        ChangeMapService.gI().changeMap(player, 127, 0, -1, 312);
    }

}
