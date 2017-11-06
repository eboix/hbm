#include <iostream>
#include <algorithm>
#include <utility>
#include <vector>
#include <cmath>
#include <cassert>

using namespace std;

typedef vector<int> vi;
typedef vector<double> vd;
typedef pair<int, int> pii;
typedef pair<double, int> pdi;
typedef pair<double, double> pdd;
typedef vector<pii> vpii;
typedef vector<vi> vvi;

/* Want to calculate I(X; Y | L_n) =
H(Y|L_n=0) - sum_{x = 0,1} p_x H(Y|X = x,L_n=0).
*/

const int MAX_M = 20;
double p[2][1<<MAX_M];
int e1[MAX_M];
int e2[MAX_M];
double Q[2][2][2];

int get_bit(int val, int i) {
	return (val >> i) % 2; 
}

void clear_states(int m) {
	for(int i = 0; i < (1<<m); i++) {
		p[0][i] = p[1][i] = 0;
	}
}

double eval_state(int vstate, int estate, int m) {
	double w = 1;
	for(int i = 0; i < m; i++) {
		int u = e1[i]; int v = e2[i];
		int us = get_bit(vstate, u);
		int vs = get_bit(vstate, v);
		int es = estate % 2;
		w *= Q[us][vs][es];
		estate = estate >> 1;
	}
	return w;
}

void add_vstate(int i, int m) {
	int v0 = get_bit(i,0);
	for(int j = 0; j < (1<<m); j++) {
		p[v0][j] += eval_state(i,j,m);
	}
	return;
}


pdd calc_entropy(vd a) {
	double norm = 0;
	double h = 0;
	for(int i = 0; i < a.size(); i++) {
		double tp = a[i];
		// cout << tp << endl;
		if(tp == 0) continue;
		norm += tp;
		h +=  tp * log2(tp);
	}
	h = h / norm;
	h = h - log2(norm);
	return pdd(norm,-h);
}

vd get_all_v0_estates(int v0, int m) {
	vd a;
	for(int i = 0; i < (1 << m); i++) {
		a.push_back(p[v0][i]);	
	}
	return a;
}

vd get_all_estates(int m) {
	vd a = get_all_v0_estates(0,m);
	vd a2 = get_all_v0_estates(1,m);
	for(int i = 0; i < a.size(); i++) {
		a[i] += a2[i];
	}
	return a;
}

double get_mut_inf(vd err, int n, vpii edge_list) {
	if(n == 1) return 1;
	for(int i = 0; i < 2; i++) {
		for(int j = 0; j < 2; j++) {                                         
			for(int k = 0; k < 2; k++) {
				int eq = 1;
				if(i != j) eq = 0;                                       
				if(k == eq) {                                             
					Q[i][j][k] = 1 - err[eq];
				}
				else {
					Q[i][j][k] = err[eq];
				}
				// cout << i << j << k << " " << Q[i][j][k] << endl;
			}
		}                                                           
	}
	
	int m = edge_list.size();

	assert(m <= MAX_M);
	for(int i = 0; i < m; i++) {
		e1[i] = edge_list[i].first;
		e2[i] = edge_list[i].second;
	}
	
	clear_states(m);
	// v_n = 0, wlog.
	for(int i = 0; i < (1<<(n-1)); i++) {
		add_vstate(i,m);
	}
	
	pdd tot_ent = calc_entropy(get_all_estates(m));
	pdd ent0 = calc_entropy(get_all_v0_estates(0,m));
	pdd ent1 = calc_entropy(get_all_v0_estates(1,m));
	
	double hy = tot_ent.second;
	double hyIx0 = (ent0.second * ent0.first + ent1.second * ent1.first) / tot_ent.first;
	
/*	cout << tot_ent.first << " " << tot_ent.second << endl;
	cout << ent0.first << " " << ent0.second << endl;
	cout << ent1.first << " " << ent1.second << endl;
	
	cout << hy << endl;
	cout << hyIx0 << endl;
	cout << (hy - hyIx0) << endl; */
	return hy - hyIx0;
}

int main() {
	vd e(2,0);
	cin >> e[0] >> e[1];
	int n, m;
	cin >> n >> m;
	vpii edge_list;
	vvi adj_list(n,vi(0,0));
	// Label 0 vs. label n.
	for(int i = 0; i < m; i++) {
		int u, v; cin >> u >> v;
		edge_list.push_back(pii(u,v));
		adj_list[u].push_back(v);
		adj_list[v].push_back(u);
	}
	double exact_mut_inf = get_mut_inf(e, n, edge_list);
	cout << exact_mut_inf << endl;
	
	// Path-counting is a bit more involved. Perhaps this is already sort of tight?
	vvi num_walks(n,vi(n,0));
	num_walks[0][0] = 1;
	for(int i = 1; i < n; i++) {
		for(int j = 0; j < n; j++) {
			for(int k = 0; k < adj_list[j].size(); k++) {
				num_walks[j][i] += num_walks[adj_list[j][k]][i-1];
			}
		}
	}
	double mut_inf_sum = 0;
	vpii tmp_edge;
	for(int i = 0; i < n; i++) {
		int curr_num = num_walks[n-1][i];
		cout << i << " " << curr_num << endl;
		if(curr_num != 0) {
			double temp_mut_inf = get_mut_inf(e, i+1, tmp_edge);
			mut_inf_sum += curr_num * temp_mut_inf;
		}
		tmp_edge.push_back(pii(i,i+1));
	}
	cout << mut_inf_sum << endl;
	
	cout << mut_inf_sum - exact_mut_inf << endl;
	assert(mut_inf_sum >= exact_mut_inf);
	
	return 0;
}
